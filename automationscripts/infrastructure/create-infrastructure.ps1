<#
Script creates ACR, ACR cubernetes, installs kubectl locally and installs mono

.HELP
.\create-infrastructure -subscriptionId "00000000-0000-0000-0000-000000000000" -ResourceGroup acsdemo1 -RegistryName "azregistry1" -RegistryAdminPassword "password1!" -KubeClusterName "acsclusterdemo1"

#>

[CmdletBinding()]
Param(
    # Subscription Id
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,

    # Resource Group
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroup,

    # Location for Resource Group and infrastructure
    [Parameter(Mandatory=$false)]
    [string]$Location="EastUS",

    # Docker Registry name
    [Parameter(Mandatory=$true)]
    [string]$RegistryName,
    
    # Docker Registry name
    [Parameter(Mandatory=$true)]
    [Security.SecureString]$RegistryAdminPassword,
   
    # Resource group for Kubernetes cluster resources
    [Parameter(Mandatory=$true)]
    [string]$KubeClusterName
    
)



Write-Host "Setting AZ subscription to $SubscriptionName..."
az account set --subscription=$SubscriptionId

if(!(az group exists --n $ResourceGroup))
{
    Write-Host "Creating resource group $ResourceGroup..."
    
    az group create --name $ResourceGroup --location $Location
}

Write-Host "Creating Registry Service $RegistryName"
az acr create -n $RegistryName -g $ResourceGroup --sku Basic --admin-enabled --location $Location


<#
Output:
{
  "adminUserEnabled": true,
  "creationDate": "2017-11-08T21:07:11.530348+00:00",
  "id": "/subscriptions/02eb72b0-4edb-4025-9e68-c604945ebc10/resourceGroups/azdkrdemo/providers/Microsoft.ContainerRegistry/registries/azdkrregistry",
  "location": "eastus",
  "loginServer": "azdkrregistry.azurecr.io",
  "name": "azdkrregistry",
  "provisioningState": "Succeeded",
  "resourceGroup": "azdkrdemo",
  "sku": {
    "name": "Basic",
    "tier": "Basic"
  },
  "status": null,
  "storageAccount": null,
  "tags": {},
  "type": "Microsoft.ContainerRegistry/registries"
}

#>
Write-Host "Setting registry admin password..."
az ad sp create-for-rbac --scopes /subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup/providers/Microsoft.ContainerRegistry/registries/$RegistryName --role Owner --password $RegistryAdminPassword

<#
Output:
Retrying role assignment creation: 1/36
{
  "appId": "8442eafb-9cb8-4045-ab87-87fd19a57bb3",
  "displayName": "azure-cli-2017-11-08-21-09-47",
  "name": "http://azure-cli-2017-11-08-21-09-47",
  "password": "stro00nGPaSSw0rd",
  "tenant": "a2b9ebf5-4b86-46a3-af5d-8b42b9c79de9"
}
#>
Write-Host "Getting registry secret credentials:"
az acr credential show -n $RegistryName -o table

<# 
Output:
USERNAME       PASSWORD                          PASSWORD2
-------------  --------------------------------  --------------------------------
azdkrregistry  fJ2ughIp/WvqvalZ1rqhQf2UrZBRubRp  We8QtYWojGLZqX/U3331IENNQZea0qgn

#>

Write-Output "Creating Kubernetes Cluster $KubeClusterName in resource group $KubeResourceGroup..."

if(-not (az group exists -n $KubeResourceGroup))
{
    az group create -n $KubeResourceGroup --location "ukwest" #$Location
}

#az aks create --resource-group $KubeResourceGroup --name $KubeClusterName --generate-ssh-keys --agent-vm-size "Standard_A2_v2" --agent-count=3 



Write-Output "Creating Kubernetes Cluster (Unmanaged)..."

az acs create --orchestrator-type=kubernetes --resource-group $ResourceGroup --name $KubeClusterName --master-count 1 --agent-vm-size "Standard_A2_v2" --agent-count=3 --generate-ssh-keys

<#
Output:
Function global:ADD-PATH()
{
    [Cmdletbinding()]
    param
    ( 
        [parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        Position=0)]
        [String[]]$AddedFolder
    )

    # Get the current search path from the environment keys in the registry.
    $OldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINESystemCurrentControlSetControlSession ManagerEnvironment' -Name PATH).Path

    # See if a new folder has been supplied.
    IF (!$AddedFolder)
    { Return 'No Folder Supplied. $ENV:PATH Unchanged'}

    # See if the new folder exists on the file system.
    IF (!(TEST-PATH $AddedFolder))
    { 
        Return 'Folder Does not Exist, Cannot be added to $ENV:PATH' 
    }

    # See if the new Folder is already in the path.
    IF ($ENV:PATH | Select-String -SimpleMatch $AddedFolder)
    { 
        Return 'Folder already within $ENV:PATH' 
    }

    # Set the New Path
    $NewPath=$OldPath+’;’+$AddedFolder

    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINESystemCurrentControlSetControlSession ManagerEnvironment' -Name PATH –Value $newPath

    # Show our results back to the world
    Return $NewPath
}
#>

#az aks get-credentials -g $KubeResourceGroupMae --name "azdemoaks"


az acs kubernetes get-credentials -g $ResourceGroup --name $KubeClusterName
<#
Output:
Merged "azk8demo-azdkrdemo-02eb72mgmt" as current context in C:\Users\sergi\.kube\config
#>


#####################################################################
#####################################################################
Write-Host "Creating folder for kubecli. This folder need to be added to the PATH variable..."
if(!(TEST-PATH "c:\cli"))
{
    mkdir c:\cli
    #Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value "$ENV:Path;c:\cli"
}

Write-Host "Installing Kubernetes CLI tool..."

az acs kubernetes install-cli --install-location "c:\cli\kubectl.exe"
<#
Output:
Downloading client to c:\cli\kubectl.exe from https://storage.googleapis.com/kubernetes-release/release/v1.8.3/bin/windows/amd64/kubectl.exe
#>

kubectl get pods




