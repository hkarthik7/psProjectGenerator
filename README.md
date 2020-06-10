# psProjectGenerator

Module for creating folder structure in PowerShell. We can declare the directories that we
use for working in PowerShell project and save it as a template. Which can then be used for
creating folder structure for the new projects.

## Getting Started

You can clone the repository or down module from output directory or install it from [PowerShell Gallery](https://www.powershellgallery.com/packages/psProjectGenerator/1.0).

Here is an example on how to import and call the module in your session. Either you can place the module in environment module paths or provide the complete path to module.

```powershell
    Install-Module -Name psProjectGenerator -Force
    Import-Module -Name psProjectGenerator -Verbose
```

Once the module is imported to the session you can create the project template with `New-PSProjectTemplate` cmdlet and pass the template path to `Invoke-PSProjectTemplate` cmdlet to create the project folder structure of your choice.

## Example

```powershell
# Create template for your project

$manifest = @{
    Path = "C:\TEMP\MyModule\MyModule.psd1"
    Author = "Name"
    Description = "My first module"
    RootModule = "MyModule.psm1"
}

New-PSProjectTemplate `
    -ProjectName "MyModule" `
    -FilePath "C:\TEMP" `
    -ProjectDirectories ("Public", "Private", "templates", "Tests") `
    -ManifestDetails $manifest `
    -Verbose

# Invoke the created template to build project folder structure

Invoke-PSProjectTemplate -TemplatePath "C:\TEMP\MyModuleTemplate.xml" -ProjectPath "C:\TEMP\MyModule" -Verbose
```

Only the Project name is mandatory parameter for `New-PSProjectTemplate`, if file path is not provided the template will be
saved in `$env:TEMP`. Also, Project Path is not mandatory for `Invoke-PSProjectTemplate` as the path will be fetched from
template file while creating folders and manifest file. It is best to provide the file path where the project has to be created while creating the template, then it can be invoked by passing only the template file.