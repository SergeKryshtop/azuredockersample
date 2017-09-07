REM http://www.jamessturtevant.com/posts/Using-the-VSTS-Docker-Agent/
REM https://github.com/Microsoft/vsts-agent-docker

docker run ^
-e VSTS_ACCOUNT="sergiikryshtop" ^
-e VSTS_TOKEN="<put>" ^
-e VSTS_WORK="/var/vsts/$VSTS_AGENT" ^
-e VSTS_AGENT="DOCKER-AGENT" ^
-e VSTS_POOL="Default" ^
-e VSTS_AGENT_URL="https://sergiikryshtop.visualstudio.com/" ^
-v /var/run/docker.sock:/var/run/docker.sock ^
-v /var/vsts:/var/vsts ^
-it microsoft/vsts-agent:ubuntu-16.04-docker-17.06.0-ce-standard

# ura3cnn2akhienh7m452lrslfxpvlg4pcnttjmgtjm46gsohl4lq