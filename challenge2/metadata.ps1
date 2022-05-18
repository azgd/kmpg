function Get-MetadataItem {
    param (
        $attribute
    )
    try {
        $output = Invoke-WebRequest -Method get -uri http://169.254.169.254/latest/meta-data/$attribute         
        if ($output.StatusCode -eq 200) {            
            return @{ $attribute = $output.Content }                       
        }
        elseif ($output.StatusCode -eq 404) {
            Write-Host "Unknown metadata attribute: $attribute"
        }
    }
    catch {
        Write-Error  "Oops: $_"
    }
}

function Get-Metadata {
    param (
        $attribute
    )
    try {
        if (!$attribute) {
            $output = @()
        (Invoke-WebRequest -Method get -uri http://169.254.169.254/latest/meta-data/).Content -split "`n" |  ForEach-Object { $output += Get-MetadataItem -attribute $_ }
            return $output | ConvertTo-Json
        }
        else {
            Get-MetadataItem -attribute $attribute | ConvertTo-Json
        }
            
    }
    catch {
        Write-Error  "Oops: $_"
    }
}