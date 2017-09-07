ENVNAME=$(get_octopusvariable "Octopus.Environment.Name")
#lowcase
ENVNAME=${ENVNAME,,}
TARGETPORT=`get_octopusvariable "ApiPort"`

APP_VERSION=`get_octopusvariable "Octopus.Release.Number"`
SQLCONNECTIONSTRING=`get_octopusvariable "SQLCONNSTR_DBConnection"`

APP_NAME=cityinfoapi-$ENVNAME
PRIVATEREGISTRYKEY=`get_octopusvariable "DockerRepositorySecretName"`

echo "App name: $APP_NAME"
echo "Db string: $SQLCONNECTIONSTRING"
echo "App Version: $APP_VERSION"
echo "Repo Secret: $PRIVATEREGISTRYKEY"

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
    "name": "cityinfoapi-$ENVNAME"
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
          "name": "cityinfoapi-$ENVNAME",
          "image": "docker.io/skryshtop/cityinfoapisample:$APP_VERSION",
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
          { "name": "$PRIVATEREGISTRYKEY" }
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
  echo "Service cityinfoapi-$ENVNAME already exists."
 else
  echo "Creating service..."
  kubectl expose deployment cityinfoapi-$ENVNAME --port=5000 --type=LoadBalancer
 fi
fi