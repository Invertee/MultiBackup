## Currently not working, currently downloads the config but doesn't get the encoding right. 

Function Encode-Base64 ($String) {
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($string)
    $EncodedText =[Convert]::ToBase64String($Bytes)
    $EncodedText
    }

Function Generate-FormAuth {
    $char = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    $char = $char.ToCharArray()
    For ($i=1;$i -le 15; $i++) {
    $ar += Get-Random -InputObject $char
    }
    $ar
}

Function Get-DraytekConfig {
    
    Param (
    [Parameter(Position=0,Mandatory=$true)] $IPAddress,
    [Parameter()] $BackupDestination,
    [Parameter()] $Username,
    [Parameter()] $Password
    )

    #Disable certificate validation
    Disable-SslValidation

    #Base URL of the controller
    $BaseURL = 'http://192.168.1.254:88/'


    #Name of the login page
    $LoginPage = 'cgi-bin/wlogin.cgi'

    $username = Encode-Base64 -String $Username
    $password = Encode-Base64 -String $Password
    $sFormAuthStr = Generate-FormAuth

    #The POST body
    $LoginBody = "aa=$($Username)&ab=$($Password)&sslgroup=-1&obj3=&obj4=&obj5=&obj6=&obj7=&sFormAuthStr=$($sFormAuthStr)"

    #Authenticate and return the session variable S1
    $Request = Invoke-WebRequest ($BaseURL + $LoginPage) -SessionVariable S1 -Method Post -Body $LoginBody

    $Backup = Invoke-RestMethod ($BaseURL + 'V2860_20180211_Pinkster_3851_BT.cfg') -WebSession $S1 -Body 'sEncryptPwd=&sEncryptCnfrmPwd=' -Method Post
    
    $Stream = $backup.RawContent -split "stream"
    $stream = $Stream[1]
    
    
    $Backup.Rawcontent | out-file "C:\Users\Admin\Desktop\File.cfg"
}


