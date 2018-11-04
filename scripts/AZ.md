

az login 

#sudo az acr login --name myregistry

#az group create --name PersonalTracker --location westus

az acr create --resource-group Playground --name pgContainerRegistry --sku Basic

$registry = 'psgivens.azurecr.io'

$registry = 'psgivens'

sudo az acr login --name $registry



