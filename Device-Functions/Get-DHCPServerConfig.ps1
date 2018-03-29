# Todo: add support for Export-DHCPServer cmdlet for Windows Server 2012+
Function Get-DHCPServerConfig {

    Param (
        [Parameter()][string]$BackupDestination,
        [Parameter()] $IPaddress
        )
    # Create new powershell remote session
    try {
        $session = New-PSSession -ComputerName $IPaddress -ErrorAction Stop
        }
    catch {
        if ($_.ErrorDetails.Message -match '(Access is denied.)')
            {
                Throw "Access is denied - PSRemoting may be disabled. Enable with 'Enable-Psremoting'"
                Break
            }
            if ($_.ErrorDetails.Message -match '(Cannot find the computer.)') 
            {
                Throw "IP/Hostname not found"
                Break
            }
    }
    
    # Exports the DHCP server to a file
    $Export = Invoke-Command -Session $session -ScriptBlock {netsh dhcp server export C:\dhcpexport.txt}
    
    If ($Export -match '(Command completed successfully.)') {
        # Reads file and outputs it to the session.
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
    # Remove remote copy of file. 
    Invoke-Command -Session $session -ScriptBlock {
        Remove-item 'C:\dhcpexport.txt' -Force
    }
    
    # Remove remote session
    Remove-PSSession $session
    # Write file on local machine.
    [system.io.file]::WriteAllBytes("$BackupDestination\DHCPExport.txt",$data)

    $path = Test-Path "$BackupDestination\DHCPExport.txt"
    if (($path -eq $true)-and ($session.State -eq 'Closed')) {Write-Output "Success!"}
}