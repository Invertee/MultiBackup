Function ConvertTo-PlainText ($PlainPassword) {
$SecurePassword = ConvertTo-SecureString $PlainPassword
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$UnsecurePassword
}

$BackupRoot = "C:\MultiBackup"

# Replace plain text passwords. 
$Config = Import-Csv "$BackupRoot\Scripts\Config.csv"
$Config | ForEach-Object {
if ($_.DevicePSWD -ne '--') {
    $DEP = $_.DevicePSWD | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
    $_.DevicePSWD = $_.DevicePSWD = '--'
    $_.DevicePSWDe = $DevicePSWDe = $DEP
}
}
$Config | Export-Csv "$BackupRoot\Scripts\Config.csv" -NoTypeInformation

# Load device config
$Devices = Import-Csv "$BackupRoot\Scripts\Config.csv"

Foreach ($Device in $Devices) {
    
    Switch ($Device.DeviceID)
    {
        'HPSwitch'
        {
            
        }
        'DellSwitch'
        'Smoothwall'
        'QNAP'
        'RuckusZonedirector'
    }
}