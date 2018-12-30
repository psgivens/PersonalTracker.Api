#!/usr/bin/pwsh

$domain='http://localhost'

#######################
# Simple pomodoro controller
#######################

Invoke-WebRequest `
  -Method Get `
  -SkipCertificateCheck `
  -Uri "$domain/api/pomodoro"

#######################
# People controller
#######################

Invoke-WebRequest `
  -Method Get `
  -SkipCertificateCheck `
  -Uri "$domain/api/people"

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

Invoke-WebRequest `
  -Method Get `
  -ContentType 'application/json' `
  -SkipCertificateCheck `
  -Uri "$domain/.well-known/openid-configuration"

$body="client_id=client&client_secret=secret&grant_type=client_credentials&scopes=api1"
$token = Invoke-RestMethod `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body $body `
  -SkipCertificateCheck `
  -Uri "$domain/connect/token"

$headers = @{
  "Authorization"="Bearer " + $token.access_token
}
$values = Invoke-RestMethod `
  -Method Get `
  -Headers $headers `
  -SkipCertificateCheck `
  -Uri "$domain/api/values"
$values


docker exec -it pomodoro-mountebank mb save --savefile gen_conf/imposters.json --removeProxies














