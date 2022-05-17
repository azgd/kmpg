# Challenge #1

> A 3 tier environment is a common setup. Use a tool of your choosing/familiarity create these resources. Please remember we will not be judged on the outcome but more focusing on the approach, style and reproducibility.

I have gone for a _modern_ 3 tier application with:

Storage Account serving static content as the front end tier.
Azure Function as the backend tier.
Azure SQL Server as the data tier.

I use symbolic links rather than wrap everything in a module and the call that module with different parameters for different environments.

This means that if a change is needed, you only need to change the files and the variables, whereas with a module you need to change the module and the calling code, obviously not all the time.
