# Powershell
$RG="privateaks"
$LOCATION="EastUS2"

az group create --name $RG --location $LOCATION

az deployment group create --resource-group $RG  -n aksdeploy --template-file azuredeploy.json