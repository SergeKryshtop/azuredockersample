#!/bin/bash

function log {
   echo $1
}

function die {
         #[ -n $1 ] && log $1
         log "Job failed!"
         exit 1
}

#export PATH=$PATH:/opt/dotnet1.2/

if [ -z "$1" ]; then
  log "build version was not provided: usage bash build.sh '<VERSION>' <ARTIFACTS OUTPUT>"
  exit 1
fi

if [ -z "$2" ]; then
  log "arttifacts output was not provided: usage bash build.sh '<VERSION>' <ARTIFACTS OUTPUT>"
  exit 1
fi

output="$2"
majorVersion=`echo $1 | cut -d _ -f 2 | cut -d . -f 1`
minorVersion=`echo $1 | cut -d _ -f 2 | cut -d . -f 2`
VERSION="$majorVersion.$minorVersion.0.0"

solutionRoot="`pwd`/../CityInfoApi"
#unitTestsLocation="$solutionRoot/**/**.csproj"
projectToPublish="$solutionRoot/CityInfo.Api/CityInfo.Api.csproj"
solutionName="CityInfoApi.sln"
cd $solutionRoot
echo "solution root: $solutionRoot"

log "Restoring dependencies..."
dotnet restore --packages "$solutionRoot/packages" /p:Version=$VERSION $solutionName
[ $? == 0 ] || die "Restoring dependencies has failed!"

log "building solution..."
dotnet build --configuration Release -v normal /p:Version=$VERSION $solutionName
[ $? == 0 ] || die "build failed!"

#log "running tests: '$unitTestsLocation'..."
#dotnet test $unitTestsLocation
#[ $? == 0 ] || die "Unit tests failed!"

log "publishing project: '$projectToPublish'..."
dotnet publish $projectToPublish --configuration Release --output $output -v normal /p:Version=$VERSION
[ $? == 0 ] || die "Publishing failed!"

#tar -czvf "$solutionRoot/CityInfoApi_$1.tar.gz" -C "$output" .
