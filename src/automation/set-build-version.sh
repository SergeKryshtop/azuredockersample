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

imageVersion=`echo $1 | cut -d _ -f 2`
majorVersion=`echo $1 | cut -d _ -f 2 | cut -d . -f 1`
minorVersion=`echo $1 | cut -d _ -f 2 | cut -d . -f 2`
VERSION="$majorVersion.$minorVersion.0.0"
#set VSTS Build Variable $(VERSION) to the release version
echo "##vso[task.setvariable variable=ProductVersion]$VERSION"
echo "##vso[task.setvariable variable=ReleaseVersion]$imageVersion"

solutionRoot="`pwd`/../CityInfoApi"
cd $solutionRoot
echo "solution root: $solutionRoot"


log "Replacing version to $VERSION in the project file '$projectToUpdate'..."

find ./ -type f -name "*.csproj"  -exec  sed -i 's|<version>[0-9a-z.A-Z-]\{1,\}</version>|<Version>14.0.1</Version>|gi' {} \;

[ $? == 0 ] || die "Version replacement failed!"

log "Done."



#tar -czvf "$solutionRoot/CityInfoApi_$1.tar.gz" -C "$output" .
