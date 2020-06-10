# dot sourcing .ps1 files
Get-ChildItem -Path "$PSScriptRoot\*.ps1" | ForEach-Object {. $_.FullName}