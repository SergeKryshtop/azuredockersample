#!/bin/bash
USAGE="usage bash deploy-buildagent.sh <VSTS_ACCOUNT_NAME> <VSTS_TOKEN> <VSTS_AGENT_NAME> [<VSTS_AGENT_QUEUE>]"


function log {
   echo $1
}

if [ -z "$1" ]; then
  log "VSTS Account Name was not provide: $USAGE"
  exit 1
fi

if [ -z "$2" ]; then
  log "VSTS Token Name was not provide: $USAGE"
  exit 1
fi

if [ -z "$3" ]; then
  log "VSTS Agent Name was not provide: $USAGE"
  exit 1
fi


VSTS_ACCOUNT_NAME="$1"
VSTS_TOKEN="$2"
VSTS_AGENT_NAME="$3"
VSTS_AGENT_QUEUE="DockerAgents"
APP_NAME="VSTS-buildAgent-$VSTS_AGENT_NAME"
IMAGE_NAME="microsoft/vsts-agent:ubuntu-16.04-docker-17.06.0-ce-standard"

if [! -z "$4" ]; then
  VSTS_AGENT_QUEUE="$4"
else 
  
fi

echo "VSTS_ACCOUNT: $VSTS_ACCOUNT_NAME"
echo "VSTS_TOKEN: $VSTS_TOKEN"
echo "VSTS_AGENT_NAME: $VSTS_AGENT_NAME"
echo "VSTS_AGENT_QUEUE: $VSTS_AGENT_QUEUE"
echo "APP_NAME: $APP_NAME"
echo "IMAGE_NAME: $IMAGE_NAME"


if  kubectl get deploy | grep $APP_NAME
then 
  echo "Deployment with the name $APP_NAME already exists. Upgrading or downgrading deployment..."
  ACTION="apply"
else
  echo "Creating new deployment $APP_NAME..."
  ACTION="create"
fi

echo "Action: $ACTION"

JSONFILE="$(mktemp)"
echo "Generating json file $JSONFILE ..."




cat <<EOF > $JSONFILE
{
  "apiVersion": "extensions/v1beta1",
  "kind": "Deployment",
  "metadata": {
    "name": "$APP_NAME"
  },
  "spec": {
  "replicas": 2,
  "minReadySeconds": 5,
  "strategy": {
  "type": "RollingUpdate"
  },
    "template": {
      "metadata": {
        "labels": {
          "app": "$APP_NAME"
        }
      },
      "spec": {
        "containers": [
         {
          "name": "$APP_NAME",
          "image": "docker.io/$IMAGE_NAME",
          "env": [
            {
              "name": "VSTS_ACCOUNT",
              "value": "$VSTS_ACCOUNT"
            },
            {
              "name": "VSTS_TOKEN",
              "value": "$VSTS_TOKEN"
            },
            {
              "name": "VSTS_WORK",
              "value": "/var/vsts/$VSTS_AGENT_NAME"
            },
            {
              "name": "VSTS_AGENT",
              "value": "$VSTS_AGENT_NAME"
            },
            {
              "name": "VSTS_POOL",
              "value": "$VSTS_AGENT_QUEUE"
            },
            {
              "name": "VSTS_AGENT_URL",
              "value": "$https://$VSTS_ACCOUNT.visualstudio.com/"
            },
             {
              "name": "VSTS_AGENT_URL",
              "value": "$https://$VSTS_ACCOUNT.visualstudio.com/"
            }
          ],
          "volumeMounts": [
            {
              "mountPath": "/var/run/docker.sock",
              "name": "docker-volume"
            }
          ]
        }],
        "volumes": [
          { 
            "name": "docker-volume",
            "hostPath": {"path": "/var/run/docker.sock"}
           }
        ]
      }
    }
  }
}
EOF

echo "Printing result JSON file: "
cat $JSONFILE

kubectl $ACTION -f $JSONFILE

