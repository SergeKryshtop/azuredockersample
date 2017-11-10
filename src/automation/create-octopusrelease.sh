#!/bin/bash

function log {
   echo $1
}

function die {
         #[ -n $1 ] && log $1
         log "Job failed!"
         exit 1
}

USAGE="usage bash octopus-createrelease.sh '<OCTOPUS_SERVER_URL>' '<PROJECT_ID>' '<RELEASE_VERSION>' '<API_KEY>' '<RELEASE_NOTES>'"
#export PATH=$PATH:/opt/dotnet1.2/

if [ -z "$1" ]; then
  log "Octopus Server Name was not provide: $USAGE"
  exit 1
fi

if [ -z "$2" ]; then
  log "Project Id was not provide: $USAGE"
  exit 1
fi

if [ -z "$3" ]; then
  log "Release version was not provided: $USAGE"
  exit 1
fi

if [ -z "$4" ]; then
  log "API KEY was not provided: $USAGE"
  exit 1
fi

OCTOPUS_SERVER_URL="$1"
PROJECT_ID="$2"
RELEASE_VERSION="$3"
API_KEY="$4"
RELEASE_NOTES="$5"


curl --verbose -k -X POST $OCTOPUS_SERVER_URL/api/releases -H "X-Octopus-ApiKey: $API_KEY" -H "Content-Type: application/json" -d '{"Version": "$RELEASE_VERSION" ,"ProjectId": "$PROJECT_ID", "ReleaseNotes":"$RELEASE_NOTES"}'

#curl --verbose -k -X POST http://mdlr-octopus.eastus.cloudapp.azure.com/api/releases -H "X-Octopus-ApiKey: API-XXXXXXXXXXXXX" -H "Content-Type: application/json" -d '{"Version": "5.0.0.1" ,"ProjectId": "Projects-41"}'

