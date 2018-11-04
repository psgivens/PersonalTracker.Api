


###################
# Note: Logins timeout causing strange authentication errors.
##############################3
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication

az login

$acrName = 'psgivens'

az acr login --name $acrName

$acrCreds = az acr credential show `
  --name psgivens `
  --query "passwords[0].value"
$acrCreds











echo $acrCreds | docker login psgivens.azurecr.io -u $acrName --password-stdin

echo $acrCreds 

docker login psgivens.azurecr.io -u $acrName --password-stdin

# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli
docker pull microsoft/aci-helloworld
docker run `
  -p 8080:80 `
  --rm `
  -it `
  microsoft/aci-helloworld


az acr list `
  --resource-group Playground `
  --query "[].{acrLoginServer:loginServer}" `
  --output table

$images = @(
  "pomodoro-idserver"
  "pomodoro-simplehtml"
  "pomodoro-watch-rapi"
  "pomodoro-pgsql"
)

$images | %{
  $post = "psgivens.azurecr.io/{0}:v1" -f $_
  docker tag $_ $post
}

docker image list | grep pomodoro

$images | %{
  $post = "psgivens.azurecr.io/{0}:v1" -f $_
  docker push $post
}

docker push psgivens.azurecr.io/aci-helloworld:v1

az acr repository list `
  --name psgivens `
  --output table

az acr repository show-tags `
  --name psgivens `
  --repository aci-helloworld `
  --output table

az acr update --name psgivens `
  --admin-enabled true

az acr credential show `
  --name psgivens `
  --query "passwords[0].value"

az container create `
  --resource-group Playground `
  --name acr-quickstart `
  --image psgivens.azurecr.io/aci-helloworld:v1 `
  --cpu 1 `
  --memory 1 `
  --registry-username psgivens `
  --registry-password 'TkladJrm5ORWR71=g3/T1L9kk39uI8rB' `
  --dns-name-label aci-demo `
  --ports 80

az container show `
  --resource-group Playground `
  --name acr-quickstart `
  --query instanceView.state

az container show `
  --resource-group Playground `
  --name acr-quickstart `
  --query ipAddress.fqdn

az container show `
  --resource-group Playground `
  --name acr-quickstart 










