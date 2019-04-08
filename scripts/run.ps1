#!/usr/bin/pwsh

Write-Host "Create Parse-JwtToken" 
#######################
# Useful powershell functions
#######################

function Parse-JwtToken {
 
    [cmdletbinding()]
    param(
      [Parameter(Mandatory=$true)][string]$Token
      #[Parameter(Mandatory=$false)][string]$OutVar
    )
 
    #Validate as per https://tools.ietf.org/html/rfc7519
    #Access and ID tokens are fine, Refresh tokens will not work
    if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { Write-Error "Invalid token" -ErrorAction Stop }
 
    #Header
    $tokenheader = $token.Split(".")[0]
    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenheader.Length % 4) { Write-Verbose "Invalid length for a Base-64 char array or string, adding ="; $tokenheader += "=" }
    Write-Verbose "Base64 encoded (padded) header:"
    Write-Verbose $tokenheader
    #Convert from Base64 encoded string to PSObject all at once
    Write-Verbose "Decoded header:"
    [System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenheader)) | ConvertFrom-Json | fl | Out-Default
 
    #Payload
    $tokenPayload = $token.Split(".")[1]
    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenPayload.Length % 4) { Write-Verbose "Invalid length for a Base-64 char array or string, adding ="; $tokenPayload += "=" }
    Write-Verbose "Base64 encoded (padded) payoad:"
    Write-Verbose $tokenPayload
    #Convert to Byte array
    $tokenByteArray = [System.Convert]::FromBase64String($tokenPayload)
    #Convert to string array
    $tokenArray = [System.Text.Encoding]::ASCII.GetString($tokenByteArray)
    Write-Verbose "Decoded array in JSON format:"
    Write-Verbose $tokenArray
    #Convert from JSON to PSObject
    $tokobj = $tokenArray | ConvertFrom-Json
    Write-Verbose "Decoded Payload:"

    if ($OutVariable) {
      Set-Variable -Name $OutVariable -Value $tokobj
    }
    
    return $tokobj
}

Write-Host "Trying using with ISE or tmux."
exit

$domain='http://localhost'

#$domain='http://localhost:2002'

#######################
# Simple ping controller
#######################

Invoke-WebRequest `
  -Method Get `
  -SkipCertificateCheck `
  -Uri "$domain/api/ping"

$body="=test"
Invoke-WebRequest `
  -Method Post `
  -Body $body `
  -ContentType 'application/x-www-form-urlencoded' `
  -SkipCertificateCheck `
  -Uri "$domain/api/ping"


#######################
# Ping DTO controller
#######################

Invoke-WebRequest `
  -Method Get `
  -SkipCertificateCheck `
  -Uri "$domain/api/pingdto"

$body = @{
    Value='Success'
} | ConvertTo-Json
Invoke-WebRequest `
  -Method Post `
  -Body $body `
  -Headers $headers `
  -ContentType 'application/json' `
  -SkipCertificateCheck `
  -Uri "$domain/api/pingdto"


#######################
# Simple ping controller
#######################

Invoke-WebRequest `
  -Method Get `
  -SkipCertificateCheck `
  -Uri "$domain/ping/ping"

$body="=test"
Invoke-WebRequest `
  -Method Post `
  -Body $body `
  -ContentType 'application/x-www-form-urlencoded' `
  -SkipCertificateCheck `
  -Uri "$domain/ping/ping"


#######################
# Ping DTO controller
#######################

Invoke-WebRequest `
  -Method Get `
  -SkipCertificateCheck `
  -Uri "$domain/ping/pingdto"

$body = @{
    Value='Success'
} | ConvertTo-Json
Invoke-WebRequest `
  -Method Post `
  -Body $body `
  -Headers $headers `
  -ContentType 'application/json' `
  -SkipCertificateCheck `
  -Uri "$domain/ping/pingdto"

#######################
# Get authentication
#######################

Invoke-RestMethod `
  -Method Get `
  -ContentType 'application/json' `
  -SkipCertificateCheck `
  -Uri "$domain/.well-known/openid-configuration"

## Client Credentials grant type
# $body="client_id=client&client_secret=secret&grant_type=client_credentials&scopes=api1"
# $token = Invoke-RestMethod `
#   -Method Post `
#   -ContentType "application/x-www-form-urlencoded" `
#   -Body $body `
#   -SkipCertificateCheck `
#   -Uri "$domain/connect/token"
# $token

# Password grant type
$body="client_id=client&client_secret=secret&grant_type=password&scopes=api1&username=js@moe&password=password123"
$token = Invoke-RestMethod `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body $body `
  -SkipCertificateCheck `
  -Uri "$domain/connect/token"
$token

$at = Parse-JwtToken $token.access_token

$auth_headers = @{
  "Authorization"="Bearer " + $token.access_token
}

$values = Invoke-RestMethod `
  -Method Get `
  -Headers $auth_headers `
  -SkipCertificateCheck `
  -Uri "$domain/api/values"
$values


docker exec -it pomodoro-mountebank mb save --savefile gen_conf/imposters.json --removeProxies



#######################
# Simple pomodoro controller
#######################

$result = Invoke-WebRequest `
  -Method Get `
  -Headers $auth_headers `
  -SkipCertificateCheck `
  -Uri "$domain/api/pomodoro"
$result

#######################
# People controller
#######################

Invoke-WebRequest `
  -Method Get `
  -Headers $auth_headers `
  -SkipCertificateCheck `
  -Uri "$domain/api/people"

#######################
# Action Item controller
#######################

Invoke-WebRequest `
  -Method Get `
  -Headers $auth_headers `
  -SkipCertificateCheck `
  -Uri "$domain/api/actionitems"

$body = Invoke-RestMethod `
  -Method Get `
  -Headers $auth_headers `
  -SkipCertificateCheck `
  -Uri "$domain/api/actionitems"


$body = @{
  UserId=$at.sub;
  Description="Some other action item"
} | ConvertTo-Json
Invoke-WebRequest `
  -Method Post `
  -Body $body `
  -Headers $auth_headers `
  -ContentType 'application/json' `
  -SkipCertificateCheck `
  -Uri "$domain/api/actionitems"


$body = @{
  Action="Complete"
  Payload="Some completion message"
} | ConvertTo-Json
Invoke-WebRequest `
  -Method Post `
  -Body $body `
  -Headers $auth_headers `
  -ContentType 'application/json' `
  -SkipCertificateCheck `
  -Uri "$domain/api/actionitems/5/action"


$body = @{
  Description = "Alternative description"
  Tags = "Today; Past Due; Future proof"
} | ConvertTo-Json
Invoke-WebRequest `
  -Method Put `
  -Body $body `
  -Headers $auth_headers `
  -ContentType 'application/json' `
  -SkipCertificateCheck `
  -Uri "$domain/api/actionitems/5"




Parse-JwtToken $token.access_token

