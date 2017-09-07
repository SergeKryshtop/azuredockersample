#!/bin/bash

docker run \
-e VSTS_ACCOUNT="*****" \
-e VSTS_TOKEN="****" \
-e VSTS_WORK="/var/vsts/$VSTS_AGENT" \
-e VSTS_AGENT="DOCKER-AGENT" \
-e VSTS_POOL="DockerAgents" \
-e VSTS_AGENT_URL="https://*****.visualstudio.com/" \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /var/vsts:/var/vsts \
-d \
-it microsoft/vsts-agent:ubuntu-16.04-docker-17.06.0-ce-standard
