

$domain='http://localhost'

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



