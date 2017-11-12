<#
.HELP 
.\run-build-container.ps1 -VSTS_ACCOUNT "sergiikryshtop" -VSTS_TOKEN "vnunqvgs4lesjhmvdytqtbtvvvyx5dqtw5gvjehx3nqt3bu7giza" 
#>
[CmdletBinding()]
param(
    #VSTS account Name, i.e.sergiikryshtop
    [Parameter(Mandatory=$true)]
    [string]$VSTS_ACCOUNT,
    #Security token. Must have at least "Agent Pools (read, manage)" permission.  (https://*********.visualstudio.com/_details/security/tokens/Edit)
    [Parameter(Mandatory=$true)]
    [string]$VSTS_TOKEN = "**********",
    #Agent name
    [Parameter(Mandatory=$true)]
    [string]$VSTS_AGENT_NAME,
    #VSTS Agent Queue where the new agent should register
    [Parameter(Mandatory=$false)]
    [string]$VSTS_AGENT_QUEUE = "DockerAgents"
)

docker run `
-e VSTS_ACCOUNT="$VSTS_ACCOUNT" `
-e VSTS_TOKEN="$VSTS_TOKEN" `
-e VSTS_WORK="/var/vsts/$VSTS_AGENT_NAME" `
-e VSTS_AGENT="$VSTS_AGENT_NAME" `
-e VSTS_POOL="$VSTS_AGENT_QUEUE" `
-e VSTS_AGENT_URL="https://$VSTS_ACCOUNT.visualstudio.com/" `
-v /var/run/docker.sock:/var/run/docker.sock `
-v /var/vsts:/var/vsts `
-d `
-it microsoft/vsts-agent:ubuntu-16.04-docker-17.06.0-ce-standard