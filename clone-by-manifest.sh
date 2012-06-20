#!/bin/bash

set -e
set -x

if [ x$REPO_SRC == "x" ] ; then
    REPO_SRC="https://dl-ssl.google.com/dl/googlesource/git-repo/repo"
fi

if [ x$ADB == "x" ] ; then
    ADB=adb
fi

# grab the project and manifest from the command line
PROJECT=$1 ; shift
MANIFEST=$1 ; shift

# If the special manifest path of 'phone' is found,
# grab the sources.xml file from the phone and use it
if [ "$MANIFEST" == "phone" ] ; then 
    echo Grabbing /system/sources.xml from your phone
    MANIFEST=$(mktemp -t sources.xml.XXXXXX)
    $ADB pull /system/sources.xml $MANIFEST
fi

# Create the project directory and the scratch directory for the
mkdir -p $PROJECT/repo_manifests
cp $MANIFEST $PROJECT/repo_manifests/default.xml


# Create the temporary manifest repository for Repo to pull from
pushd $PROJECT/repo_manifests &> /dev/null
git init && git add default.xml && git commit -m "Creating repo sync tree"
man_repo=$PWD
popd &>/dev/null


# Get repo and initialize it using the temporary manifest repository
cd $PROJECT
curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > repo 
chmod +x repo
./repo init -u repo_manifests
./repo sync

cd ..

echo All done!  There is a repository located at $PROJECT/repo_manifests
echo that contains the manifest you specified.  It is called default.xml
echo to make work with the repo tool a little simpler.  You can update
echo your clone by doing:
echo    $ echo my_manifest_file > $PROJECT/repo_manifests
echo    $ cd $PROJECT/repo_manifests
echo    $ git commit -m "updating manifest" default.xml
echo    $ cd ..
echo    $ ./repo sync
