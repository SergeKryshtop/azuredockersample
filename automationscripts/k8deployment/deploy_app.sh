ENVNAME=$(get_octopusvariable "Octopus.Environment.Name")
#lowcase
ENVNAME=${ENVNAME,,}
TARGETPORT=`get_octopusvariable "ApiPort"`

APP_VERSION=`get_octopusvariable "Octopus.Release.Number"`
SQLCONNECTIONSTRING=`get_octopusvariable "SQLCONNSTR_DBConnection"`
K8_APP_NAME=`get_octopusvariable "K8AppName"`



APP_NAME=$K8_APP_NAME-$ENVNAME
PRIVATE_REGISTRY_KEY=`get_octopusvariable "DockerRepositorySecretName"`
IMAGE_NAME=`get_octopusvariable "DockerImageName"`




echo "App name: $APP_NAME"
echo "Db string: $SQLCONNECTIONSTRING"
echo "App Version: $APP_VERSION"
echo "Repo Secret: $PRIVATE_REGISTRY_KEY"
echo "Image Name: $IMAGE_NAME"


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
          "app": "cityinfoapi-$ENVNAME"
        }
      },
      "spec": {
        "containers": [
         {
          "name": "$APP_NAME",
          "image": "$IMAGE_NAME:$APP_VERSION",
          "env": [
            {
              "name": "SQLCONNSTR_DBConnection",
              "value": "$SQLCONNECTIONSTRING"
            }
          ],
          "ports": [
            {
              "name": "http",
              "containerPort": 5000
            }
          ]
        }],
        "imagePullSecrets": [
          { "name": "$PRIVATE_REGISTRY_KEY" }
        ]
      }
    }
  }
}
EOF

echo "Printing result JSON file: "
cat $JSONFILE

kubectl $ACTION -f $JSONFILE


if [ $ACTION == "create" ]
then
 if  kubectl get service | grep $APP_NAME 
 then
  echo "Service $APP_NAME already exists."
 else
  echo "Creating service..."
  kubectl expose deployment $APP_NAME --port=5000 --type=LoadBalancer
 fi
fi