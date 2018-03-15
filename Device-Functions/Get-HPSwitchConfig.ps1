Function Get-HPSwitchConfig {
    
    Param (
    [Parameter(Position=0,Mandatory=$true)] $IPAddress,
    [Parameter()] $BackupDestination,
    [Parameter()] [bool] $DontModifySwitchSettings = $false,
    [Parameter()] $Username,
    [Parameter()] $Password
    )

    # Verify POSH-SSH is available.
    if (!(Get-Module -ListAvailable -Name Posh-SSH)) {
    Write-Warning "Posh-SSH Module not installed! Install it using: 'Install-Module -Name Posh-SSH'"
    Break
    }

    if (($username) -and ($password)) {
        $passwd = ConvertTo-SecureString "$Password" -AsPlainText -Force
        $DeviceCredentials = New-Object System.Management.Automation.PSCredential ("$Username", $passwd)
    }

    try {$Session = New-SFTPSession -ComputerName $IPAddress -Credential $DeviceCredentials -AcceptKey -ErrorAction stop} 
    catch {$ErrorMessage = $_.Exception.Message}

    if ($ErrorMessage) {
    if ($ErrorMessage -like "*IP file transfer not enabled*") {
        if (-not($DontModifySwitchSettings)) {
        Write-Verbose "SFTP disabled - Attempting to enable."
        $Session = New-SSHSession -ComputerName $IPAddress -Credential $DeviceCredentials -AcceptKey
        $Stream = $Session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
        $Stream.Write("`n")
        Start-Sleep 5
        $Stream.Write("config`n")
        Start-Sleep 5
        $Stream.Write("ip ssh filetransfer`n")
        Remove-SSHSession -SessionId $Session.SessionId
        } else {
        Write-Error "SFTP is disabled!"
        }
    }
    
    if ($ErrorMessage -like "*Permission denied*") {
    Write-error "Credentials incorrect"
    Break
    }
    }

    if ($Session) {
    Get-SFTPContent -SessionId $Session.SessionID -Path "/cfg/running-config" | Out-file "$BackupDestination\running-config"
    Get-SFTPContent -SessionId $Session.SessionID -Path "/cfg/startup-config" | Out-file "$BackupDestination\startup-config"
    $removed = Remove-SFTPSession -SessionId $Session.SessionID 
    }
    $path = Test-Path "$BackupDestination\startup-config"
    if (($path -eq $true)-and ($removed -eq $true)) {Write-Output "Success!"}
}

