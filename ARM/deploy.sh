#!/bin/bash
set -e   # stop on error
RG="privateaks"
AKS="aksCluster1"
LOCATION="EastUS2"
SSHKEYFILE="akslabkey"
#SSHPUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlDHE6NsyOYy53U1G5zG3NbTdJOD54zrdcEdwYTJOTmIEkpfmSUjD/gIKgoM3s5vBfs/SeWCO8hQ/WxSDYYneJhldBmw40dg0n/tCDH7/5xrrwqhs3obKqkQ3R2ZwUTaHMkKkQx4fyZ/5SD+ii1IqxnyNnpvHIUib2yw2lhlGLuye+t65JlsNAYAo6sHaCe5Sdb1jFuOK79YF8mgfIKe6O3/evBFJMZ+TJ9yJXwyRBojL8k3xpXiJtSpOuZHIXVu+FesN/gWOUyLb3tua3uwK0NhmK84pTFFUB/fkQimGmfsFcv9hRh8PIIWIDq1FlhZkJubb1prWmMO374t6HvVuz"

# create ssh key file if it does not already exist
if [ ! -f $SSHKEYFILE ]; then
    ssh-keygen -f $SSHKEYFILE
fi
SSHPUBKEY=$(cat "$SSHKEYFILE.pub")

az group create --name $RG --location $LOCATION

az deployment group create --resource-group $RG  -n aksdeploy --template-file azuredeploy.json \
    --parameters sshpubkey="$SSHPUBKEY"


AKSid=$(az aks show -n $AKS -g $RG --output tsv --query id)
echo "==========================="
echo ">>>>>  You will need to copy this Service Principal information into a GitHub Secret -- see instructions"
echo "==========================="
az ad sp create-for-rbac --sdk-auth --scope $AKSid --output json
