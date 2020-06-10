function Invoke-PSProjectTemplate {
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