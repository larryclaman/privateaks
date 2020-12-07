# Private AKS & Github runner

This repo contains two main assets:

### ARM Template to create a private AKS cluster & associated assets
The arm template creates:
- A Private AKS cluster
  - Cluster uses a system assign identity (MSI)
- An Ubuntu server to be used as a GitHub runner
  - VM is created with private IP only
  - GitHub Runner self hosted build server needs to be manually installed per [instructions](https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/adding-self-hosted-runners)
  - Any tools needed by the build server (eg, Docker, Azure CLI, kubectl, Dotnet, etc) will also need to be manually installed on the runner
  - You will likely want to change the SSH key so that you can log into the VM
- A VNET with three subnets
  - vmsubnet - for vm deployment
  - akssubnet - for aks deployment
  - AzureBastionSubnet - used if you deploy Azure Bastion service (not included in this arm template)
- A role assignment for the AKS resource granting it contributor access to the akssubnet


### APP:  Deploy simple app to AKS cluster
The workflow deploy.yml deploys the simple Azure Voting app to the private AKS cluster.  A Service Principal must be created & saved as a Secret called AZURE_AKS_CREDENTIALS prior to running the workflow; eg
```
az ad sp create-for-rbac --sdk-auth
```
And, this Service Principal must be granted appropriate rights (eg, aks contributor) to the AKS cluster.