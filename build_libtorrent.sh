#!/bin/sh

LIBTORRENT_DARWIN_ROOT=$(pwd)
LIBTORRENT_ROOT=$LIBTORRENT_DARWIN_ROOT/libtorrent
BOOST_ROOT=$LIBTORRENT_DARWIN_ROOT/boost
BOOST_BUILD_ROOT=$BOOST_ROOT/tools/build/src
BOOST_BUILD_PATH=$BOOST_ROOT/b2
USER_CONFIG_JAM=$LIBTORRENT_DARWIN_ROOT/user-config.jam

TOOLSET_GROUPS=(
    "darwin-iphone_arm64"
    "darwin-iphonesimulator_arm64:darwin-iphonesimulator_x86_64"
    "darwin-appletv_arm64"
    "darwin-appletvsimulator_x86_64:darwin-appletvsimulator_arm64"
    "darwin-mac_x86_64:darwin-mac_arm64"
)

export BOOST_ROOT
export BOOST_BUILD_PATH

# set bash script to exit immediately if any commands fail.
set -e

# boost

echo "💬 looking for Boost.Build"
if [ -f "$BOOST_BUILD_PATH" ]; then
    echo "💬 Boost.Build found"
else
    echo "💬 Boost.Build not found"
    echo "💬 moving to ${BOOST_ROOT}"
    cd $BOOST_ROOT
    echo "💬 building b2"
    ./bootstrap.sh --with-toolset=clang
    echo "💬 building Boost"
    ./b2
    echo "💬 writing boost-build.jam"
    echo "boost-build ${BOOST_BUILD_ROOT} ;" > $LIBTORRENT_DARWIN_ROOT/boost-build.jam
fi

# libtorrent

echo "💬 moving to ${LIBTORRENT_ROOT}"
cd $LIBTORRENT_ROOT

#for TOOLSET_GROUP in ${TOOLSET_GROUPS[@]} ; do
#    IFS=':' read -ra TOOLSETS <<< "$TOOLSET_GROUP"
#    for TOOLSET in "${TOOLSETS[@]}"; do
#        echo "💬 building libtorrent static for ${TOOLSET}"
#        $BOOST_BUILD_PATH --user-config=$USER_CONFIG_JAM threading=multi link=static runtime-link=static variant=release toolset=$TOOLSET
#        echo "💬 building libtorrent shared for ${TOOLSET}"
#        $BOOST_BUILD_PATH --user-config=$USER_CONFIG_JAM threading=multi link=shared runtime-link=shared variant=release toolset=$TOOLSET
#    done
#done

# Static XCFramework

echo "💬 moving to ${LIBTORRENT_DARWIN_ROOT}"
cd $LIBTORRENT_DARWIN_ROOT

LIBTORRENT_FAT_BIN_PATH=./bin/

LIBTORRENT_PRODUCT_PATH=/release/cxxstd-14-iso/link-static/threading-multi/
LIBTORRENT_PRODUCT_NAME=libtorrent-rasterbar.a

TRY_SIGNAL_PRODUCT_PATH=/release/cxxstd-14-iso/fpic-on/link-static/threading-multi/
TRY_SIGNAL_PRODUCT_NAME=libtry_signal.a

LIBTORRENT_HEADERS_PATH=./libtorrent/include/libtorrent
BOOST_HEADERS_PATH=./boost/boost
TRY_SIGNAL_HEADERS_PATH=./libtorrent/deps/try_signal

HEADERS_PATH=./include
FINAL_PRODUCT_NAME=libtorrent.a

cp -rf $LIBTORRENT_HEADERS_PATH "${HEADERS_PATH}/libtorrent"
cp -rf $BOOST_HEADERS_PATH "${HEADERS_PATH}/boost"
cp -f ${TRY_SIGNAL_HEADERS_PATH}/*.hpp "${HEADERS_PATH}/"

CREATE_XCFRAMEWORK="xcodebuild -create-xcframework "

for TOOLSET_GROUP in ${TOOLSET_GROUPS[@]} ; do

    CREATE_FAT_LIBTORRENT_ARCHIVE="lipo -create"
    CREATE_FAT_TRY_SIGNAL_ARCHIVE="lipo -create"
    
    IFS=':' read -ra TOOLSETS <<< "$TOOLSET_GROUP"
    for TOOLSET in "${TOOLSETS[@]}"; do
        CREATE_FAT_LIBTORRENT_ARCHIVE="${CREATE_FAT_LIBTORRENT_ARCHIVE} libtorrent/bin/${TOOLSET}${LIBTORRENT_PRODUCT_PATH}${LIBTORRENT_PRODUCT_NAME}"
        CREATE_FAT_TRY_SIGNAL_ARCHIVE="${CREATE_FAT_TRY_SIGNAL_ARCHIVE} libtorrent/deps/try_signal/bin/${TOOLSET}${TRY_SIGNAL_PRODUCT_PATH}${TRY_SIGNAL_PRODUCT_NAME}"
    done

    IFS='_' read -ra TOOLSET_NAME <<< "$TOOLSET_GROUP"
    TOOLSET_NAME=${TOOLSET_NAME[0]}

    mkdir -p ${LIBTORRENT_FAT_BIN_PATH}${TOOLSET_NAME}${LIBTORRENT_PRODUCT_PATH}

    echo "💬 create fat archive for ${TOOLSET_NAME}"
    $CREATE_FAT_LIBTORRENT_ARCHIVE -output ${LIBTORRENT_FAT_BIN_PATH}${TOOLSET_NAME}${LIBTORRENT_PRODUCT_PATH}${LIBTORRENT_PRODUCT_NAME}
    $CREATE_FAT_TRY_SIGNAL_ARCHIVE -output ${LIBTORRENT_FAT_BIN_PATH}${TOOLSET_NAME}${LIBTORRENT_PRODUCT_PATH}${TRY_SIGNAL_PRODUCT_NAME}

    libtool -static -o ${LIBTORRENT_FAT_BIN_PATH}${TOOLSET_NAME}${LIBTORRENT_PRODUCT_PATH}${FINAL_PRODUCT_NAME} \
                       ${LIBTORRENT_FAT_BIN_PATH}${TOOLSET_NAME}${LIBTORRENT_PRODUCT_PATH}${LIBTORRENT_PRODUCT_NAME} \
                       ${LIBTORRENT_FAT_BIN_PATH}${TOOLSET_NAME}${LIBTORRENT_PRODUCT_PATH}${TRY_SIGNAL_PRODUCT_NAME}

    CREATE_XCFRAMEWORK="${CREATE_XCFRAMEWORK} -library ${LIBTORRENT_FAT_BIN_PATH}${TOOLSET_NAME}${LIBTORRENT_PRODUCT_PATH}${FINAL_PRODUCT_NAME} -headers ${HEADERS_PATH}"

done

$CREATE_XCFRAMEWORK -output LibTorrent.xcframework


#echo "💬 Copying build"
#cd $LIBTORRENT_SWIFT_ROOT
#mkdir -p bin/iphone/{static,shared} bin/iphonesimulator/{static,shared} bin/appletv/{static,shared} bin/appletvsimulator/{static,shared} bin/mac/{static,shared}
#cp libtorrent/bin/darwin-iphone/release/cxxstd-14-iso/instruction-set-arm64/link-static/threading-multi/libtorrent.a bin/iphone/static
#cp libtorrent/bin/darwin-iphone/release/cxxstd-14-iso/instruction-set-arm64/threading-multi/libtorrent.dylib bin/iphone/shared
#cp libtorrent/bin/darwin-iphonesimulator/release/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/iphonesimulator/static
#cp libtorrent/bin/darwin-iphonesimulator/release/cxxstd-14-iso/threading-multi/libtorrent.dylib bin/iphonesimulator/shared
#
#cp libtorrent/bin/darwin-appletv/release/cxxstd-14-iso/instruction-set-arm64/link-static/threading-multi/libtorrent.a bin/appletv/static
#cp libtorrent/bin/darwin-appletv/release/cxxstd-14-iso/instruction-set-arm64/threading-multi/libtorrent.dylib bin/appletv/shared
#cp libtorrent/bin/darwin-appletvsimulator/release/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/appletvsimulator/static
#cp libtorrent/bin/darwin-appletvsimulator/release/cxxstd-14-iso/threading-multi/libtorrent.dylib bin/appletvsimulator/shared
#
#cp libtorrent/bin/darwin-mac/release/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/mac/static
#cp libtorrent/bin/darwin-mac/release/cxxstd-14-iso/threading-multi/libtorrent.dylib bin/mac/shared
#
#cp boost/bin.v2/libs/system/build/darwin-iphone/release/cxxstd-14-iso/instruction-set-arm64/threading-multi/visibility-hidden/libboost_system.dylib bin/iphone/shared
#cp boost/bin.v2/libs/system/build/darwin-iphonesimulator/release/cxxstd-14-iso/threading-multi/visibility-hidden/libboost_system.dylib bin/iphonesimulator/shared
#cp boost/bin.v2/libs/system/build/darwin-appletv/release/cxxstd-14-iso/instruction-set-arm64/threading-multi/visibility-hidden/libboost_system.dylib bin/appletv/shared
#cp boost/bin.v2/libs/system/build/darwin-appletvsimulator/release/cxxstd-14-iso/threading-multi/visibility-hidden/libboost_system.dylib bin/appletvsimulator/shared
#cp boost/bin.v2/libs/system/build/darwin-mac/release/cxxstd-14-iso/threading-multi/visibility-hidden/libboost_system.dylib bin/mac/shared
#echo "💬 Copying build DONE !"
#
#echo "💬 Copying headers !"
#mkdir -p bin/headers
#cp -r boost/boost bin/headers
#cp -r libtorrent/include/libtorrent bin/headers
#echo "💬 Copying headers DONE !"
#
#echo "💬 Building XCFramework"
#mkdir -p bin/framework/static
#xcodebuild -create-xcframework \
#           -library bin/iphone/static/libtorrent.a -headers bin/headers \
#           -library bin/iphonesimulator/static/libtorrent.a -headers bin/headers \
#           -library bin/appletv/static/libtorrent.a -headers bin/headers \
#           -library bin/appletvsimulator/static/libtorrent.a -headers bin/headers \
#           -library bin/mac/static/libtorrent.a -headers bin/headers \
#           -output bin/framework/static/LibTorrent.xcframework
#
#cd bin/framework/static/LibTorrent.xcframework
#ARCH_DIRS=$(/bin/ls -d */)
#cd $LIBTORRENT_SWIFT_ROOT
#cp -rf bin/headers bin/framework/static/LibTorrent.xcframework/Headers
#cd bin/framework/static/LibTorrent.xcframework
#for ARCH_DIR in $ARCH_DIRS;
#do
#  rm -rf "${ARCH_DIR}/Headers"
#  ln -sfh ../Headers "${ARCH_DIR}/Headers"
#done
#echo "💬 Building static XCFramework DONE !"
