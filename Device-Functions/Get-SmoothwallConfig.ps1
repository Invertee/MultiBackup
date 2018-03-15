# Currently backs devices up but needs some logic to detemine which backup to select and download on the device. 

Get-SmoothwallConfig {

    Param(
        [Parameter(Mandatory=$true)] $IPAddress,
        [Parameter(Mandatory=$true)] $BackupDestination,
        [Parameter(Mandatory=$true)] $Username,
        [Parameter(Mandatory=$true)] $Password,
        [Parameter()] $Port = '441'
    )

    # Allow all SSL schemes
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    Disable-SslValidation

    $port = '441'
    $URI = 'https://'
    $URI += $IPAddress
    $Port = ':'+$port
    $Login += '/cgi-bin/login.cgi?'
    $AuthBody = "vxuse=$($Username)&vxpss=$($Password)&ref=%25252Fcgi-bin%25252Findex.cgi&action=Login"

    $backupstring = 'ORDER=Ascending&COLUMN=3&main-TITLE=AUTOBACKUP&main-COMMENT=&buoMASTER=on&main-updates=on&main-certs=on&main-ethernet=on&main-general=on&main-censord=on&main-networking=on&main-remoteaccess=on&main-reports=on&main-database=on&main-safeguarding=on&main-replication=on&main-services=on&main-tenants=on&main-ups=on&main-portal=on&zap-enable=on&auth-enable=on&auth-byod=on&auth-googleauth=on&dhcp-enable=on&ftp-enable=on&guardian3-alerts=on&guardian3-customelements=on&guardian3-authexception=on&guardian3-authpolicy=on&guardian3-androidconnect=on&guardian3-logs=on&guardian3-mitmcerts=on&guardian3-localproxy=on&guardian3-mobileguardian+proxy+server=on&guardian3-proxy=on&guardian3-swconnect=on&guardian3-swurl=on&guardian3-sgupstreamproxies=on&guardian3-wccp=on&guardian3-guardianpolicy=on&heartbeat-enable=on&ids-idssettings=on&ids-ipssettings=on&ids-intrusiondb=on&im-enable=on&monitor-alerts=on&monitor-output=on&monitor-groups=on&reverseproxy-reverseproxy_settings=on&routing-routingsettings=on&sip-sipsettings=on&snmp-snmpsettings=on&tunnel-enable=on&zone-enable=on&action=Save+and+backup'

    $Auth = Invoke-WebRequest ($URI + $Port + $Login) -SessionVariable s1 -Method Post -Body $AuthBody
    $Backup = Invoke-WebRequest ($URI + $Port + '/cgi-bin/admin/backup.img') -WebSession $s1 -Body $backupstring -Method Post

    $Download = Invoke-WebRequest ($URI + $Port + '/cgi-bin/admin/backup.img') -Body '4=on&mode=Download' -WebSession $s1 -Method Post

     [System.IO.File]::WriteAllBytes($BackupDestination'\Smoothwall.tgz', $Download.Content)


    $div = $Archives.ParsedHtml.getElementById("maincontainer")
    $div = $div.childNodes | Where-Object NodeName -eq div
    $div = $div.children | Where-Object NodeName -EQ DIV
    # Authenticate and return the session variable s1
    
    
    Try {

            } 
        Catch [System.Net.WebException] {
            Throw "Unable to connect to target IP"   
            }
    


$url = "https://10.10.0.90:441"
$web = New-Object Net.WebClient
$output = $web.DownloadString($url)
