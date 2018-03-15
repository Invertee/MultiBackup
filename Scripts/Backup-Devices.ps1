$BackupRoot = "C:\MultiBackup"

# Replace plain text passwords. 
$Config = Import-Csv $BackupRoot\Config.csv
$Config | ForEach-Object {
if ($_.DevicePSWD -ne '--') {
    $DEP = $_.DevicePSWD | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
    $_.DevicePSWD = $_.DevicePSWD = '--'
    $_.DevicePSWDe = $DevicePSWDe = $DEP
}
}
$Config | Export-Csv $BackupRoot\Config.csv -NoTypeInformation