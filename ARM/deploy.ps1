# Powershell
$ErrorActionPreference="Stop"
$RG="privateaks1"
$AKS="aksCluster1"
$LOCATION="EastUS2"
$SSHKEYFILE="akslabkey1"

# create ssh file if it does not already exist
If (-Not (Test-Path -Path .\$SSHKEYFILE )) { 
    ssh-keygen -f $SSHKEYFILE
 }
$SSHPUBKEY = Get-Content .\$SSHKEYFILE.pub

az group create --name $RG --location $LOCATION
az deployment group create --resource-group $RG  -n aksdeploy --template-file azuredeploy.json `
    --parameters sshpubkey=$SSHPUBKEY

$AKSid=$(az aks show -n $AKS -g $RG --output tsv --query id)
echo "==========================="
echo ">>>>>   You will need to copy this Service Principal information into a GitHub Secret -- see instructions"
echo "==========================="
az ad sp create-for-rbac --sdk-auth --scope $AKSid --output json