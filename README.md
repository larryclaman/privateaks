# Private AKS & GitHub runner

This repo contains two main assets:  
1) An ARM template to deploy a private private AKS cluster, a VM, and a VNET.  The VM will be used as a private GitHub runner
2) A GitHub workflow that deploys a sample voting app to the private AKS cluster

You will need to fork a copy of this repo into your own GitHub Account or Org.

## ARM Template 
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

### Deploying the ARM Template
1. Clone the repo locally and then cd into the ARM folder.
2. In your favorite editor, edit the defaults in either the `deploy.ps1` (powershell) or the `deploy.sh` (bash).  Note you will need to create a new ssh key (using `ssh-keygen`) and then paste this into the variable in the deployment script.  Be sure to save the private key as you will need it later in order to ssh into the build server.
3. Run either the `deploy.ps1` or the `deploy.sh` to deploy the resources to Azure.
4. Once the script finishes, you will need to manually create an [Azure Bastion Service](https://docs.microsoft.com/en-us/azure/bastion/tutorial-create-host-portal) and attach it to the VNET that was just created.
5. Once the Baston Service has been created, use it to ssh into the VM.
6. On this VM, you will need to install any tooling that might be needed by the GitHub Runner agent.  This will likely include:
   - [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script):
        ```
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo ./get-docker.sh
        ```
   - [Azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt)
      ```
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
      ```
   - kubectl:
      ```
      sudo az aks install-cli
      ```
7. Install the Self Hosted GitHub Runner agent by following the steps on [this page](https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/adding-self-hosted-runners)
   - Follow the steps to add a self-hosted agent to a repository
   - Addtionally install the runner as a service (see https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/configuring-the-self-hosted-runner-application-as-a-service)



## APP:  Deploy simple app to AKS cluster
Once the runner has been configured, you can use the included workflow to deploy an app to the private cluster through the following steps:

1. Create a  Service Principal must be created & saved as a Secret called AZURE_AKS_CREDENTIALS prior to running the workflow; eg
```
az ad sp create-for-rbac --sdk-auth
```
And, this Service Principal must be granted appropriate rights (eg, aks contributor) to the AKS cluster.

2. (Optionally) Change the defaults in the `deployapp.yml` file to reflect the resource group & AKS cluster name.  (If you don't change the defaults, you will need to enter them when you run the workflow.)
3. Within your GitHub repo, browse to 'Actions', select the 'DeployToAKS' workflow, and then select the 'Run Workflow' button to manuall run this workflow.
4. The workflow will deploy the sample app to the cluster.  You can test this by running the following from a command line on the build server:
```
az aks get-credentials -n <AKSCLUSTERNAME> -g <RESOURCEGROUPNAME>  # one time only
kubectl get all --namespace vote
```