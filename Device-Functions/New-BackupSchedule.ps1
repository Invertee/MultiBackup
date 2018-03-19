function Get-DeviceData {    
    
    Param(
            [Parameter(Mandatory=$true)][string]$DeviceSelected,
            [Parameter(Mandatory=$true)][string]$DeviceID,
            [Parameter(Mandatory=$true)][int]$Deviceno,
            [Parameter()][bool]$PortRequired
            )  

Write-Host "$DeviceSelected Selected!"

    $DeviceName = Read-host -Prompt "Name of Device"
    While (-not($DeviceIP)) {
        $DeviceIP = Read-Host -Prompt "Device IP Address or hostname"
        }
    While (-not($DeviceUser)) { 
        $DeviceUser = Read-Host -Prompt "Device Username"
        }
    While (-not($DevicePSWD)) {
        $DevicePSWD = Read-Host -Prompt "Device Password (Will be encrypted on first backup run)"
        }
    if ($PortRequired) {$DevicePort = Read-host -Prompt "Port used for backing up device"}

    $object = $null
    $object = New-Object -TypeName PSObject
    $object | Add-Member -Name "Deviceno" -MemberType NoteProperty -Value $Deviceno
    $object | Add-Member -Name "DeviceID" -MemberType NoteProperty -Value $DeviceID
    $object | Add-Member -Name "DeviceName" -MemberType NoteProperty -Value $DeviceName
    $object | Add-Member -Name "DeviceIP" -MemberType NoteProperty -Value $DeviceIP
    $object | Add-Member -Name "DeviceUser" -MemberType NoteProperty -Value $DeviceUser
    $object | Add-Member -Name "DevicePSWD" -MemberType NoteProperty -Value $DevicePSWD
    $object | Add-Member -Name "DevicePSWDe" -MemberType NoteProperty -Value ""
    $object | Add-Member -Name "DevicePort" -MemberType NoteProperty -Value $DevicePort
    
    Return $object
}   

Function New-BackupSchedule {

    Param(
        [Parameter()] $BackupRoot = "C:\MultiBackup"
    )

$Devicelist = @()

While (-not($running)) {
Clear-Host
Write-Host "

### Step 1 ###
Add Devices:

1 = HP Procurve Switch
2 = Dell Switch
3 = Smoothwall
4 = Sonicwall 
5 = Ruckus Zonedirector Controller
6 = Draytek Router

### Step 2 ###
S = Save config and configure backup schedule.

Q = Quit
"
$Option = Read-Host -Prompt "Please select an option."

switch ($Option)
{
    "1" {
        $Deviceno++
        $object = Get-DeviceData -DeviceSelected "HPSwitch" -DeviceID "HPSwitch" -Deviceno $Deviceno
        $Devicelist += $object
        $Devicelist | Select-Object -Property "DeviceID","DeviceName","DeviceIP","DeviceUser" | Format-table -Auto 
        }

    "2" {
        $Deviceno++
        $object = Get-DeviceData -DeviceSelected "DellSwitch" -DeviceID "DellSwitch" -Deviceno $Deviceno
        $Devicelist += $object
        $Devicelist | Select-Object -Property "DeviceID","DeviceName","DeviceIP","DeviceUser" | Format-table -Auto 

        } 
    "3" {        
        $Deviceno++
        $object = Get-DeviceData -DeviceSelected "Smoothwall" -DeviceID "Smoothwall" -Deviceno $Deviceno
        $Devicelist += $object
        $Devicelist | Select-Object -Property "DeviceID","DeviceName","DeviceIP","DeviceUser" | Format-table -Auto 
        }
    
    "4" {
        $Deviceno++
        $object = Get-DeviceData -DeviceSelected "Sonicwall" -DeviceID "Sonicwall" -Deviceno $Deviceno
        $Devicelist += $object
        $Devicelist | Select-Object -Property "DeviceID","DeviceName","DeviceIP","DeviceUser" | Format-table -Auto 
        } 
    
    "5" {
        $Deviceno++
        $object = Get-DeviceData -DeviceSelected "RuckusZonedirector" -DeviceID "Ruckus" -Deviceno $Deviceno
        $Devicelist += $object
        $Devicelist | Select-Object -Property "DeviceID","DeviceName","DeviceIP","DeviceUser" | Format-table -Auto 
        } 
        
    "S" {
        $ABF = Test-Path $BackupRoot
        If ($ABF -eq $false) {New-Item -Path "$BackupRoot\Backups" -ItemType Directory | Out-Null}

        $Devicelist | Select-Object -Property "DeviceID","DeviceName","DeviceIP","DeviceUser" | Format-table -Auto 
        
        # Asks to Overwrite Config
        $ConfigAlreadyExist = Test-path "$BackupRoot\Config.csv"
        if ($ConfigAlreadyExist -eq $true) {
        [ValidateSet('Y','N')]$Answer = Read-Host "Overwrite Config?"
        If ($Answer -eq 'Y') {$Devicelist | Export-Csv -path "$BackupRoot\Config.csv" -Force | out-null
        }
        } ELSE {$Devicelist | Export-Csv -path "$BackupRoot\Config.csv" | out-null}

        # Copy backup script from module directory
        $ListModules = Get-Module 'MultiBackup' -ListAvailable
        $ModulePath = $ListModules.ModuleBase 
        Copy-Item "$ModulePath\Scripts\Backup-Devices.ps1" $BackupRoot

        # Remove any existing task and creates a new one.
        $taskexist = Get-ScheduledTask "MultiBackup"
        if ($taskexist) {Unregister-ScheduledTask MultiBackup -Confirm:$false}
    
        $taskaction = New-ScheduledTaskAction -Execute powershell.exe -Argument "-executionpolicy bypass -noninteractive -file $BackupRoot\Backup-Devices.ps1"
        $tasktrigger = New-ScheduledTaskTrigger -Weekly -At "12AM" -DaysOfWeek 1
        $TaskSettings = New-ScheduledTaskSettingsSet -MultipleInstances 2 
        Register-ScheduledTask -Action $taskaction -Trigger $tasktrigger -TaskName "MultiBackup" -Settings $TaskSettings -User "System" -Force
        }

    "Q" {$running = 'no!'}

    }
    

} 

}