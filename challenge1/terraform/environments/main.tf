data "azurerm_client_config" "main" {}

resource "azurerm_resource_group" "group" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = azurerm_resource_group.group.name
  tenant_id           = data.azurerm_client_config.main.tenant_id

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = true
  sku_name                        = "standard"
}

resource "azurerm_role_assignment" "function_app_role" {

  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id

}

resource "azurerm_role_assignment" "support_team" {

  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "0484bc5c-7eb4-4e99-8ff6-a67b1afb34b2" # This is X Team

}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.group.name
  location            = var.location
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.group.name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~4"
  #daily_memory_time_quota    = 1

  identity {
    type = "SystemAssigned"
  }

  app_settings = {

    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"

  }

  connection_string {
    name  = "VaultUri"
    type  = "Custom"
    value = azurerm_key_vault.main.vault_uri
  }

  connection_string {
    name  = "StorageAccount"
    type  = "Custom"
    value = azurerm_storage_account.storage_account.primary_blob_connection_string
  }

  connection_string {
    name  = "Database"
    type  = "SQLAzure"
    value = "Server=tcp:${var.sql_server_name}.database.windows.net,1433;Initial Catalog=token;Persist Security Info=False;User ID=${var.sql_server_administrator};Password=${random_password.password.result};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

}

resource "random_password" "password" {
  length           = 16
  min_lower        = 1
  min_numeric      = 1
  min_upper        = 1
  min_special      = 1
  override_special = "!$%"

}


resource "azurerm_mssql_server" "sql_server" {
  name                          = var.sql_server_name
  resource_group_name           = azurerm_resource_group.group.name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.sql_server_administrator
  administrator_login_password  = random_password.password.result
  minimum_tls_version           = 1.2
  public_network_access_enabled = false

}

resource "azurerm_mssql_elasticpool" "elastic_pool" {
  name                = var.elastic_pool_name
  resource_group_name = azurerm_resource_group.group.name
  location            = var.location
  server_name         = azurerm_mssql_server.sql_server.name
  license_type        = "LicenseIncluded"
  max_size_gb         = 50

  sku {
    name     = "StandardPool"
    tier     = "Standard"
    capacity = 50
  }

  per_database_settings {
    min_capacity = 10
    max_capacity = 20
  }

  lifecycle {
    ignore_changes = [license_type] # For some reason this keeps popping up as a change even though it's the same value
  }
}

resource "azurerm_mssql_database" "database" {
  name            = "token"
  server_id       = azurerm_mssql_server.sql_server.id
  sku_name        = "ElasticPool"
  elastic_pool_id = azurerm_mssql_elasticpool.elastic_pool.id
}

resource "azurerm_key_vault_secret" "username" {
  name         = "sql-server-administrator-username"
  value        = var.sql_server_administrator
  key_vault_id = azurerm_key_vault.main.id
  depends_on = [
    azurerm_role_assignment.support_team
  ]
}

resource "azurerm_key_vault_secret" "password" {
  name         = "sql-server-administrator-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.main.id
  depends_on = [
    azurerm_role_assignment.support_team
  ]
}
