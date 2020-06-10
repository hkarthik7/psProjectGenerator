function New-PSProjectTemplate {
    <#
    .SYNOPSIS
        New-PSProjectTemplate creates a template for PowerShell Project and saves in xml file.
    .DESCRIPTION
        New-PSProjectTemplate is intented to create a project folder structure for PowerShell
        projects. Like any other programming languages PowerShell doesn't have a predefined
        project structure. To keep the working simple New-PSProjectTemplate helps to save the
        project folders and manifest details in xml file and use it when needed.
    .EXAMPLE
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
    .EXAMPLE
        New-PSProjectTemplate -ProjectName "MyModule" -Verbose
    .PARAMETER ProjectName
        Provide the project name, this will be the module name.
    .PARAMETER FilePath
        Provide the file path to save the template. If not provided template will be saved
        in $env:TEMP path.
    .PARAMETER ProjectDirectories
        Provide the list of directories that has to be created for your project.
    .PARAMETER ManifestDetails
        Provide the details that has to be added in module manifest file.
    .NOTES
        Author					Version			Date			Notes
        -------------------------------------------------------------------------------
        harish.karthic		    v1.0			10/06/2020		Initial script
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectName,

        [Parameter(Mandatory = $false)]
        [string]$FilePath,

        [Parameter(Mandatory = $false)]
        [object[]]$ProjectDirectories,

        [Parameter(Mandatory = $false)]
        [hashtable]$ManifestDetails
    )
    
    begin {
        Write-Verbose "Begin.."
        # initialize function parameters
        $psVersion = [string]::Format("{0}.{1}", $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor)

        # default parameters
        if (-not ($PSBoundParameters.ContainsKey("FilePath"))) {
            $FilePath = $env:TEMP
            Write-Warning "FilePath is not provided, saving the template in $($FilePath)"
        }
        if (-not ($PSBoundParameters.ContainsKey("ProjectDirectories"))) {
            $ProjectDirectories = @("Classes", "Public", "Private", "Tests", "en-US")
        }
        if (-not ($PSBoundParameters.ContainsKey("ManifestDetails"))) {
            $ManifestDetails = @{
                Path = "$FilePath\$ProjectName\$ProjectName.psd1"
                Guid = New-Guid
                Author = $env:USERNAME
                RootModule = "$ProjectName.psm1"
                PowerShellVersion = $psVersion
                Description = "Module for $ProjectName"
            }
        }
        
    }
    
    process {
        Write-Verbose "Creating project template in $($FilePath).."

        $xml = @"
<?xml version='1.0' encoding='utf-8' ?>
<Configuration>
    <ProjectName>$ProjectName</ProjectName>
    <Directories>$($ProjectDirectories -join ",")</Directories>
    <ManifestData>
"@
        $stringBuilder = New-Object -TypeName System.Text.StringBuilder
        $stringBuilder.Append($xml) > $null

        foreach ($key in $ManifestDetails.Keys) {
            $stringBuilder.Append("`n`t`t<$key>$($ManifestDetails[$key])</$key>") > $null
        }

        $stringBuilder.Append("`n`t</ManifestData>`n</Configuration>") > $null

        # exporting template
        $stringBuilder.ToString() | Out-File "$FilePath\$($ProjectName)Template.xml"

    }
    
    end {
        Write-Verbose "End.."
    }
}