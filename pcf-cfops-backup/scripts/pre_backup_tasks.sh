#!/bin/bash
set -xe

# prime jumpbox with cfops and s3cmd tools
export BUILD_ROOT_DIR=/tmp
# create destination directory for cfops files on jumpbox
echo Creating cfops directory on jumpbox
sshpass -p "$JUMPBOX_SSH_PASSWORD" ssh -o "StrictHostKeyChecking=no" "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS bash -c "'mkdir -p $BUILD_ROOT_DIR/cfops/plugins'"
# copy cfops files to jumbox
echo Copying cfops directory to jumpbox
sshpass -p "$JUMPBOX_SSH_PASSWORD" scp -o "StrictHostKeyChecking=no" -pr ./cfops/* "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS:$BUILD_ROOT_DIR/cfops

if [ "$FILE_TRANSFER_METHOD" == "s3cmd" ]; then
    # copy s3cmd tool to jumpbox
    echo Copying s3cmd release to jumpbox
    sshpass -p "$JUMPBOX_SSH_PASSWORD" scp -o "StrictHostKeyChecking=no" -pr ./s3cmd-release/* "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS:$BUILD_ROOT_DIR

    sshpass -p "$JUMPBOX_SSH_PASSWORD" ssh -o "StrictHostKeyChecking=no" "$JUMPBOX_SSH_USER"@$JUMPBOX_ADDRESS \
       bash -c "'
        echo Preparing s3cmd files
        cd $BUILD_ROOT_DIR
        tar xfv s3cmd-*.tar.gz
        rm s3cmd-*.tar.gz
        mv s3cmd* s3cmd

        echo Installing required Python packages by s3cmd
        set -e
        sudo apt-get update
        sudo apt-get install python-dateutil
        set +e

        ./s3cmd/s3cmd --version
      '"
fi