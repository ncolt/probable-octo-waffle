[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$url = "https://www.microsoft.com/" 
$req = [Net.HttpWebRequest]::Create($url)
$req.ServicePoint
$req.GetResponse()
$url = "https://www.microsoft.com/"
# Create a (thread-safe) hashtable to hold any certificates discovered
$certTable = [hashtable]::Synchronized(@{})

# Create a handler
$handler = [System.Net.Http.HttpClientHandler]::new()

# Attach a custom validation callback that saves the remote certificate to the hashtable
$handler.ServerCertificateCustomValidationCallback = {
  param(
    [System.Net.Http.HttpRequestMessage]$Msg,
    [System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert,
    [System.Security.Cryptography.X509Certificates.X509Chain]$Chain,
    [System.Net.Security.SslPolicyErrors]$SslErrors
  )

  # Save the certificate
  $certTable[$Msg.RequestUri] = $Cert

  # Leave actual policy validation as-is
  return [System.Net.Security.SslPolicyErrors]::None -eq $SslErrors
}.GetNewClosure()

# Create a new http client with our custom handler attached
$client = [System.Net.Http.HttpClient]::new($handler)

# Prepare request message
$request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $url)

# Send request
$response = $client.Send($request)

# callback routine will now have populated the table with the certificate
$certTable[$request.RequestUri]

100
600
300
100
