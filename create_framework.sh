#!/bin/sh

if [ "$#" -ne 3 ]; then
    echo "Usage: create_framework.sh <BIN_NAME> <FRAMEWORK_NAME> <HEADERS_PATH>"
    exit
fi

BIN_NAME="$1"
FRAMEWORK_NAME="$2"
HEADERS_PATH="$3"

mkdir -p $FRAMEWORK_NAME.framework/Versions/A/{Headers,Modules}
cp -rf $HEADERS_PATH $FRAMEWORK_NAME.framework/Versions/A/Headers
lipo -create $BIN_NAME -output $FRAMEWORK_NAME.framework/Versions/A/$FRAMEWORK_NAME
ln -sfh A $FRAMEWORK_NAME.framework/Versions/Current
ln -sfh Versions/Current/Headers $FRAMEWORK_NAME.framework/Headers
ln -sfh Versions/Current/Modules $FRAMEWORK_NAME.framework/Modules
ln -sfh Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_NAME.framework/$FRAMEWORK_NAME
