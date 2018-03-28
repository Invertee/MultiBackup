# Dot source all powershell scripts. 
Get-ChildItem -Path $PSScriptRoot\*.ps1 -Recurse | Foreach-Object{ . $_.FullName }

$FunctionsToExport = @(
    'Get-DraytekConfig',
    'Get-HPSwitchConfig',
    'Get-ZonedirectorConfig',
    'Get-SmoothwallConfig',
    'Get-QNAPConfig'
    'New-BackupSchedule',
    'Disable-SslValidation'
)

Export-ModuleMember -Function $FunctionsToExport