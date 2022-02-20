#!/bin/sh

LIBTORRENT_DARWIN_ROOT="$PWD"

BOOST_ROOT="$PWD/boost"
BOOST_BUILD="$BOOST_ROOT/b2"
BOOST_BUILD_JAM="$PWD/boost-build.jam"
BOOST_USER_CONFIG="$PWD/user-config.jam"

LIBTORRENT_ROOT="$PWD/libtorrent"

OPENSSL_ROOT="$PWD/openssl"
OPENSSL_INCLUDE="$OPENSSL_ROOT/include"
OPENSSL_ARM_CONFIGURATION=darwin64-arm64-cc
OPENSSL_X86_64_CONFIGURATION=darwin64-x86_64-cc

IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
IPHONESIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
APPLETVOS_SDK=$(xcrun --sdk appletvos --show-sdk-path)
APPLETVSIMULATOR_SDK=$(xcrun --sdk appletvsimulator --show-sdk-path)
MACOS_SDK=$(xcrun --sdk macosx --show-sdk-path)

print_paths() {
    echo BOOST_ROOT $BOOST_ROOT
    echo BOOST_BUILD $BOOST_BUILD
    echo BOOST_BUILD_JAM $BOOST_BUILD_JAM
    
    echo LIBTORRENT_ROOT $LIBTORRENT_ROOT
    
    echo OPENSSL_ROOT $OPENSSL_ROOT
    echo OPENSSL_INCLUDE $OPENSSL_INCLUDE
    
    echo IPHONEOS_SDK $IPHONEOS_SDK
    echo IPHONESIMULATOR_SDK $IPHONESIMULATOR_SDK
    echo APPLETVOS_SDK $APPLETVOS_SDK
    echo APPLETVSIMULATOR_SDK $APPLETVSIMULATOR_SDK
    echo MACOS_SDK $MACOS_SDK
}

build_openssl() {
    local SDK=$1
    local CONFIGURATION=$2

    export CROSS_TOP="${SDK%%/SDKs/*}"
    export CROSS_SDK="${SDK##*/SDKs/}"
    
    echo CROSS_TOP $CROSS_TOP
    echo CROSS_SDK $CROSS_SDK
 
    cd $OPENSSL_ROOT
    ./Configure $CONFIGURATION no-engine no-async no-shared
        
    make
    
    local BIN_PATH="$OPENSSL_ROOT/build/$CROSS_SDK/$CONFIGURATION"
    
    mkdir -p $BIN_PATH
    
    cp -f libssl.a libcrypto.a $BIN_PATH
    
    make clean
    
    cd $LIBTORRENT_DARWIN_ROOT
 
    unset CROSS_TOP
    unset CROSS_SDK
}

build_openssl_all_sdk_and_archs() {
    build_openssl $IPHONEOS_SDK $OPENSSL_ARM_CONFIGURATION
    build_openssl $IPHONESIMULATOR_SDK $OPENSSL_ARM_CONFIGURATION
    build_openssl $IPHONESIMULATOR_SDK $OPENSSL_X86_64_CONFIGURATION

    build_openssl $APPLETVOS_SDK $OPENSSL_ARM_CONFIGURATION
    build_openssl $APPLETVSIMULATOR_SDK $OPENSSL_ARM_CONFIGURATION
    build_openssl $APPLETVSIMULATOR_SDK $OPENSSL_X86_64_CONFIGURATION

    build_openssl $MACOS_SDK $OPENSSL_ARM_CONFIGURATION
    build_openssl $MACOS_SDK $OPENSSL_X86_64_CONFIGURATION
}

build_boost_b2() {
    printf "boost-build %s/tools/build/src ;" "$BOOST_ROOT" > "$BOOST_BUILD_JAM"
    cd $BOOST_ROOT
    ./bootstrap.sh
    cd $LIBTORRENT_DARWIN_ROOT
}

build_boost() {
    local TOOLSET=$1
    cd $BOOST_ROOT
    $BOOST_BUILD "--user-config=$BOOST_USER_CONFIG" link=static variant=release "toolset=$TOOLSET"
    cd $LIBTORRENT_DARWIN_ROOT
}

build_boost_all_sdk_and_archs() {
    build_boost clang-iphone_arm64
    build_boost clang-iphonesimulator_arm64
    build_boost clang-iphonesimulator_x86_64
    build_boost clang-appletv_arm64
    build_boost clang-appletvsimulator_arm64
    build_boost clang-appletvsimulator_x86_64
    build_boost clang-mac_arm64
    build_boost clang-mac_x86_64
}

build_libtorrent() {
    local TOOLSET=$1
    export BOOST_ROOT
    cd $LIBTORRENT_ROOT
    $BOOST_BUILD "--user-config=$BOOST_USER_CONFIG" link=static variant=release "toolset=$TOOLSET"
    cd $LIBTORRENT_DARWIN_ROOT
}

build_libtorrent_all_sdk_and_archs() {
    build_libtorrent clang-iphone_arm64
#    build_libtorrent clang-iphonesimulator_arm64
#    build_libtorrent clang-iphonesimulator_x86_64
#    build_libtorrent clang-appletv_arm64
#    build_libtorrent clang-appletvsimulator_arm64
#    build_libtorrent clang-appletvsimulator_x86_64
#    build_libtorrent clang-mac_arm64
#    build_libtorrent clang-mac_x86_64
}

set -e

print_paths

#build_openssl_all_sdk_and_archs

build_boost_b2

#build_boost_all_sdk_and_archs

build_libtorrent_all_sdk_and_archs
