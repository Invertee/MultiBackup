Function Get-SmoothwallConfig {

    Param(
        [Parameter(Mandatory=$true)] $IPAddress,
        [Parameter(Mandatory=$true)] $BackupDestination,
        [Parameter(Mandatory=$true)] $Username,
        [Parameter(Mandatory=$true)] $Password,
        [Parameter()] $Port = '441',
        [Parameter()] [bool] $Includelogfiles = $false
    )
    # Disable SSL cert validation
    Disable-SslValidation

    # Prepare URI
    $port = '441'
    $URI = 'https://'
    $URI += $IPAddress
    $Port = ':'+$port
    $Login += '/cgi-bin/login.cgi?'
    $AuthBody = "vxuse=$($Username)&vxpss=$($Password)&ref=%25252Fcgi-bin%25252Findex.cgi&action=Login"
    $Backupstring = 'ORDER=Ascending&COLUMN=3&main-TITLE=AUTOBACKUP&main-COMMENT=&buoMASTER=on&main-updates=on&main-certs=on&main-ethernet=on&main-general=on&main-censord=on&main-networking=on&main-remoteaccess=on&main-reports=on&main-database=on&main-safeguarding=on&main-replication=on&main-services=on&main-tenants=on&main-ups=on&main-portal=on&zap-enable=on&auth-enable=on&auth-byod=on&auth-googleauth=on&dhcp-enable=on&ftp-enable=on&guardian3-alerts=on&guardian3-customelements=on&guardian3-authexception=on&guardian3-authpolicy=on&guardian3-androidconnect=on&guardian3-logs=on&guardian3-mitmcerts=on&guardian3-localproxy=on&guardian3-mobileguardian+proxy+server=on&guardian3-proxy=on&guardian3-swconnect=on&guardian3-swurl=on&guardian3-sgupstreamproxies=on&guardian3-wccp=on&guardian3-guardianpolicy=on&heartbeat-enable=on&ids-idssettings=on&ids-ipssettings=on&ids-intrusiondb=on&im-enable=on&monitor-alerts=on&monitor-output=on&monitor-groups=on&reverseproxy-reverseproxy_settings=on&routing-routingsettings=on&sip-sipsettings=on&snmp-snmpsettings=on&tunnel-enable=on&zone-enable=on&action=Save+and+backup'
    $Backuplogs = 'ORDER=Ascending&COLUMN=3&main-TITLE=AUTOBACKUP&main-COMMENT=&buoMASTER=on&main-updates=on&main-certs=on&main-ethernet=on&main-general=on&main-censord=on&main-networking=on&main-remoteaccess=on&main-reports=on&main-database=on&main-safeguarding=on&main-replication=on&main-services=on&main-tenants=on&main-ups=on&main-portal=on&zap-enable=on&auth-enable=on&auth-byod=on&auth-googleauth=on&dhcp-enable=on&ftp-enable=on&guardian3-alerts=on&guardian3-customelements=on&guardian3-authexception=on&guardian3-authpolicy=on&guardian3-androidconnect=on&guardian3-logs=on&guardian3-mitmcerts=on&guardian3-localproxy=on&guardian3-mobileguardian+proxy+server=on&guardian3-proxy=on&guardian3-swconnect=on&guardian3-swurl=on&guardian3-sgupstreamproxies=on&guardian3-wccp=on&guardian3-guardianpolicy=on&heartbeat-enable=on&ids-idssettings=on&ids-ipssettings=on&ids-intrusiondb=on&im-enable=on&monitor-alerts=on&monitor-output=on&monitor-groups=on&reverseproxy-reverseproxy_settings=on&routing-routingsettings=on&sip-sipsettings=on&snmp-snmpsettings=on&tunnel-enable=on&zone-enable=on&lidMASTER=on&main-Admin+UI+log=on&main-Boot+activity+log=on&main-Central+monitor+log=on&main-Firewall+event+log=on&main-Guardian+access+logs=on&main-Guardian+error+logs=on&main-Guardian+web+server+access+logs=on&main-Guardian+web+server+error+logs=on&main-IM+logs=on&main-Intrusion+detection+logs=on&main-Intrusion+prevention+logs=on&main-Portal+access+log=on&main-Proxy+access+logs=on&main-Proxy+cache+logs=on&main-Reverse+Proxy+access+logs=on&main-Reverse+Proxy+cache+logs=on&main-SystemD+error+log=on&main-Traffic+bandwidth+log=on&main-Webserver+access+log=on&main-Webserver+error+Log=on&main-Webserver+global+access+Log=on&main-Webserver+global+error+Log=on&main-Webserver+security+service=on&action=Save+and+backup'
    if ($Includelogfiles) {$Backupstring = $Backuplogs}

    # Authenticate with Smoothwall and retreive session
    $Auth = Invoke-WebRequest ($URI + $Port + $Login) -SessionVariable s1 -Method Post -Body $AuthBody
    if ($auth.ParsedHtml.IHTMLDocument2_body.outerText -match 'Incorrect username or password') {throw "Incorrect Username/Password"}
    # Create full backup on the Smoothwall and return backup ID
    $Backup = Invoke-WebRequest ($URI + $Port + '/cgi-bin/admin/backup.img') -WebSession $s1 -Body $Backupstring -Method Post
    $BackupCount = ($Backup.forms[0].Fields.Count -1).ToString()
    $BackupCount += '=on&mode=Download'
    # Download backup config file and write file contents 
    $Download = Invoke-WebRequest ($URI + $Port + '/cgi-bin/admin/backup.img') -Body $BackupCount -WebSession $s1 -Method Post
    [System.IO.File]::WriteAllBytes("$BackupDestination\Smoothwall.tgz", $Download.Content)
    # Delete the backup copy on Smoothwall
    $Deletestring = $BackupCount -replace 'Download','Delete'
    $Delete = Invoke-WebRequest ($URI + $Port + '/cgi-bin/admin/backup.img') -Body $Deletestring -WebSession $s1 -Method Post

}