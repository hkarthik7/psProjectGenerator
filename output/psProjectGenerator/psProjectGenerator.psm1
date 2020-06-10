# dot sourcing .ps1 files
Export-ModuleMember -Function *-*
Get-ChildItem -Path "$PSScriptRoot\*.ps1" | ForEach-Object {. $_.FullName}