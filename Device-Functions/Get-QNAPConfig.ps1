Function Get-QNAPConfig {
    
    Param (
    [Parameter(Position=0,Mandatory=$true)] $IPAddress,
    [Parameter()] $BackupDestination,
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

    $Session = New-SFTPSession -ComputerName $IPAddress -credential $DeviceCredentials -AcceptKey -ErrorAction stop 

    if ($ErrorMessage -like "*Permission denied*") {
        Write-error "Credentials incorrect"
        Break
        }

    try {
        $latest = Get-SFTPChildItem -SessionId $session.SessionID -Path '/share/CACHEDEV1_DATA/.@backup_config' | Where-Object -Property Fullname -Match '(0_)'}
        catch {
            if ($_.exception -match '(does not exist)') {
            # Possibly an older QNAP
            $latest = Get-SFTPChilditems -SessionId $session.SessionID -Path '/share/MD0_DATA/.@backup_config' | Where-Object -Property Fullname -Match '(0_)'
        }
        }

    if ($Session) {
    Get-SFTPContent -SessionId $Session.SessionID -Path $latest.Fullname | Out-file "$BackupDestination\QNAPconfig.tar.gz"
    $removed = Remove-SFTPSession -SessionId $Session.SessionID 
    }
    $path = Test-Path "$BackupDestination\QNAPconfig.tar.gz"
    if (($path -eq $true)-and ($removed -eq $true)) {Write-Output "Success!"}
}

