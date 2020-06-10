function New-PSProjectTemplate {
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