Function Get-ZonedirectorConfig {

    Param(
        [Parameter(Mandatory=$true)] $IPAddress,
        [Parameter()] $BackupDestination,
        [Parameter(Mandatory=$true)] $Username,
        [Parameter(Mandatory=$true)] $Password
        )
    
    Disable-SslValidation

    $Username = $Username.ToLower()
    $BaseURL = 'https://'
    $BaseURL += $IPAddress
    $BaseURL += '/admin/'
    $AuthBody = "username=$($Username)&password=$($Password)&ok=Log+In"

    If (-not $BackupDestination) {$BackupDestination = "."}
    
    # Authenticate and return the session variable s1
    Try {
    $Auth = Invoke-WebRequest ($BaseURL + 'login.jsp') -SessionVariable s1 -Method Post -Body $AuthBody
        if ($auth.ParsedHtml.IHTMLDocument2_body.innerText -match "you entered is incorrect") {
            Throw "Incorrect Username/Password"
        }
    $Request = Invoke-WebRequest ($BaseURL + 'login.jsp') -WebSession $s1 -Method Get
        } 
    Catch [System.Net.WebException] {
        Throw "Unable to connect to target IP"   
        }
    # Downloads backup and writes it to the backup destination. 
    $Download = Invoke-WebRequest ($BaseURL + "_savebackup.jsp?time=010118_00_00") -WebSession $s1 -Method Get 
    [System.IO.File]::WriteAllBytes("$BackupDestination\ZDConfig.bak", $Download.content)
}




