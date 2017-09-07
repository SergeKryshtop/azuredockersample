#!/bin/bash

function log { 
   echo $1
}

function die {
         [ -n $1 ] && log $1
         log "Job failed!"
         exit 1
}

#export PATH=$PATH:/opt/dotnet1.2/

if [ -z "$1" ]; then
  log "build version was not provided: usage bash build.sh '<VERSION>'"
  exit 1
fi

VERSION=$1
solutionRoot="`pwd`/../CityInfoApi"
output="$solutionRoot/buildArtifacts"
#unitTestsLocation="$solutionRoot/**/**.csproj"
projectToPublish="$solutionRoot/CityInfo.Api/CityInfo.Api.csproj"
cd $solutionRoot

log "Restoring dependencies..."
dotnet restore --packages "$solutionRoot/packages" /p:Version=$VERSION
[ $? == 0 ] || die "Restoring dependencies has failed!"

log "building solution..."
dotnet build --configuration Release -v normal /p:Version=$VERSION
[ $? == 0 ] || die "build failed!"

#log "running tests: '$unitTestsLocation'..."
#dotnet test $unitTestsLocation
#[ $? == 0 ] || die "Unit tests failed!"

log "publishing project: '$projectToPublish'..."
dotnet publish $projectToPublish --configuration Release --output $output -v normal /p:Version=$VERSION
[ $? == 0 ] || die "Publishing failed!"

tar -czvf "$WORKSPACE/LeisureApp_$VERSION.tar.gz" -C "$output" .