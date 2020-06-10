function Invoke-PSProjectTemplate {
    <#
    .SYNOPSIS
        Invoke-PSProjectTemplate creates the folder structure for the project from
        provided template file.
    .DESCRIPTION
        Invoke-PSProjectTemplate get the details from template file created by
        New-PSProjectTemplate and creates folder structure, module and manifest
        files. This is the skeleton of your project to start working with.
    .EXAMPLE
        Invoke-PSProjectTemplate -TemplatePath "C:\TEMP\MyModuleTemplate.xml" -ProjectPath "C:\TEMP\MyModule" -Verbose
    .PARAMETER TemplatePath
        Provide the path of the template file. All the project details are fetched from this template.
        To create template run New-PSProjectTemplate.
    .PARAMETER ProjectPath
        Provide the path where project has to be created.
    .NOTES
        Author					Version			Date			Notes
        -------------------------------------------------------------------------------
        harish.karthic		    v1.0			10/06/2020		Initial script
        harish.karthic		    v1.0			10/06/2020		Added to module
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplatePath,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectPath
    )
    
    begin {
        Write-Verbose "Begin.."
    }
    
    process {
        try {
            [xml]$fileContents = Get-Content $TemplatePath

            if (-not ($PSBoundParameters.ContainsKey("ProjectPath"))) {
                Write-Warning "ProjectPath is not provided, using path from template.."
                
                $ProjectPath = Split-Path $fileContents.Configuration.ManifestData.Path
            }             

            Write-Verbose "Creating project folder structure from given template.."

            # creating project folder
            New-Item -Path $ProjectPath -ItemType Directory | Out-Null
            New-Item -Path $ProjectPath -Name $fileContents.Configuration.ManifestData.RootModule -ItemType File | Out-Null

            # create module manifest from template
            $moduleManifest = [ordered]@{}

            $fileContents.Configuration.ManifestData.ChildNodes | ForEach-Object {
                $moduleManifest[$_.Name] = $_.'#text'
            }

            New-ModuleManifest @moduleManifest

            # creating project folders from template
            foreach ($item in $fileContents.Configuration.Directories.Split(",")) {
                New-Item -Path $ProjectPath -Name $item -ItemType Directory | Out-Null
            }
            
        }
        catch {
            Write-Host $_ -ForegroundColor Red
        }
    }
    
    end {
        Write-Verbose "End.."
    }
}
Export-ModuleMember -Function Invoke-PSProjectTemplate