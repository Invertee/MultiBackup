function Disable-SslValidation {
    # Allow all SSL schemes
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

    if (-not ([System.Management.Automation.PSTypeName]"TrustEverything").Type)
    {
    Add-Type -TypeDefinition  @"
        using System.Net.Security;
        using System.Security.Cryptography.X509Certificates;
        public static class TrustEverything
    {
        private static bool ValidationCallback(object sender, X509Certificate certificate, X509Chain chain,
        SslPolicyErrors sslPolicyErrors) { return true; }
        public static void SetCallback() { System.Net.ServicePointManager.ServerCertificateValidationCallback = ValidationCallback; }
        public static void UnsetCallback() { System.Net.ServicePointManager.ServerCertificateValidationCallback = null; }
}
"@
    }
    [TrustEverything]::SetCallback()
}