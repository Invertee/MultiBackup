Function Get-DHCPServerConfig {

    Param (
        [Parameter()][string]$BackupDestination,
        [Parameter()] $IPaddress
        )

    $session = New-PSSession -ComputerName $IPaddress

    $Export = Invoke-Command -Session $session -ScriptBlock {netsh dhcp server export C:\dhcpexport.txt}
    
    If ($Export -match '(Command completed successfully.)') {

    $data = Invoke-Command -Session $session -ScriptBlock {
    $file = [system.io.file]::ReadAllBytes('C:\dhcpexport.txt')    
    $file

    }
    } else {
    if ($Export -match '(command was not found)') {
        Write-Error "DHCP Server not found."
        Break
    }
    }

Invoke-Command -Session $session -ScriptBlock {
    Remove-item 'C:\dhcpexport.txt' -Force
    }
    Remove-PSSession $session


[system.io.file]::WriteAllBytes("$BackupDestination\DHCPExport.txt",$data)

}