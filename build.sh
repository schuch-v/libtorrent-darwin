#!/bin/sh

LIBTORRENT_DARWIN_ROOT="$PWD"

BOOST_ROOT="$PWD/boost"
BOOST_BUILD="$BOOST_ROOT/b2"
BOOST_BUILD_JAM="$PWD/boost-build.jam"
BOOST_USER_CONFIG="$PWD/user-config.jam"

LIBTORRENT_ROOT="$PWD/libtorrent"

OPENSSL_ROOT="$PWD/openssl"
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
    $BOOST_BUILD link=static variant=release toolset=$TOOLSET --user-config=$BOOST_USER_CONFIG
    cd $LIBTORRENT_DARWIN_ROOT
}

build_boost_all_sdk_and_archs() {
    build_boost darwin-iphone_arm64
    build_boost darwin-iphonesimulator_arm64
    build_boost darwin-iphonesimulator_x86_64
    build_boost darwin-appletv_arm64
    build_boost darwin-appletvsimulator_arm64
    build_boost darwin-appletvsimulator_x86_64
    build_boost darwin-mac_arm64
    build_boost darwin-mac_x86_64
}

build_libtorrent() {
    local TOOLSET=$1
    local OPENSSL_LIB="${2##*/SDKs/}"
    local OPENSSL_INCLUDE=$OPENSSL_ROOT/include
    export BOOST_ROOT
    cd $LIBTORRENT_ROOT
    $BOOST_BUILD openssl-lib=$OPENSSL_LIB openssl-include=$OPENSSL_INCLUDE  link=static variant=release toolset=$TOOLSET --user-config=$BOOST_USER_CONFIG
    cd $LIBTORRENT_DARWIN_ROOT
}

build_libtorrent_all_sdk_and_archs() {
    build_libtorrent darwin-iphone_arm64 $IPHONEOS_SDK
    build_libtorrent darwin-iphonesimulator_arm64 $IPHONESIMULATOR_SDK
    build_libtorrent darwin-iphonesimulator_x86_64 $IPHONESIMULATOR_SDK
    build_libtorrent darwin-appletv_arm64 $APPLETVOS_SDK
    build_libtorrent darwin-appletvsimulator_arm64 $APPLETVSIMULATOR_SDK
    build_libtorrent darwin-appletvsimulator_x86_64 $APPLETVSIMULATOR_SDK
    build_libtorrent darwin-mac_arm64 $MACOS_SDK
    build_libtorrent darwin-mac_x86_64 $MACOS_SDK
}

create_xcframework() {
    cd $LIBTORRENT_DARWIN_ROOT
        
    local APPLETV_ARM64="$LIBTORRENT_ROOT/bin/darwin-appletv_arm64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"
    local APPLETVSIMULATOR_ARM64="$LIBTORRENT_ROOT/bin/darwin-appletvsimulator_arm64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"
    local APPLETVSIMULATOR_X86_64="$LIBTORRENT_ROOT/bin/darwin-appletvsimulator_x86_64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"
    local APPLETVSIMULATOR_ARM64_X86_64="$LIBTORRENT_ROOT/bin/darwin-appletvsimulator_arm64_x86_64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"

    local IPHONE_ARM64="$LIBTORRENT_ROOT/bin/darwin-iphone_arm64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"
    local IPHONESIMULATOR_ARM64="$LIBTORRENT_ROOT/bin/darwin-iphonesimulator_arm64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"
    local IPHONESIMULATOR_X86_64="$LIBTORRENT_ROOT/bin/darwin-iphonesimulator_x86_64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"
    local IPHONESIMULATOR_ARM64_X86_64="$LIBTORRENT_ROOT/bin/darwin-iphonesimulator_arm64_x86_64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"

    local MAC_ARM64="$LIBTORRENT_ROOT/bin/darwin-mac_arm64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"
    local MAC_X86_64="$LIBTORRENT_ROOT/bin/darwin-mac_x86_64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"
    local MAC_ARM64_X86_64="$LIBTORRENT_ROOT/bin/darwin-mac_arm64_x86_64/release/cxxstd-14-iso/link-static/threading-multi/visibility-hidden/libtorrent-rasterbar.a"

    mkdir -p $(dirname $APPLETVSIMULATOR_ARM64_X86_64)
    mkdir -p $(dirname $IPHONESIMULATOR_ARM64_X86_64)
    mkdir -p $(dirname $MAC_ARM64_X86_64)

    echo "create fat library for appletvsimulator arm64 & x86-64..."
    lipo -create $APPLETVSIMULATOR_ARM64 $APPLETVSIMULATOR_X86_64 -output $APPLETVSIMULATOR_ARM64_X86_64
    echo "create fat library for iphonesimulator arm64 & x86-64..."
    lipo -create $IPHONESIMULATOR_ARM64 $IPHONESIMULATOR_X86_64 -output $IPHONESIMULATOR_ARM64_X86_64
    echo "create fat library for mac arm64 & x86-64..."
    lipo -create $MAC_ARM64 $MAC_X86_64 -output $MAC_ARM64_X86_64

    local INCLUDE="$PWD/libtorrent/include"
    
    local XCFRAMEWORK_CREATE="xcodebuild -create-xcframework "
    
    XCFRAMEWORK_CREATE+="-library $APPLETV_ARM64 -headers $INCLUDE "
    XCFRAMEWORK_CREATE+="-library $APPLETVSIMULATOR_ARM64_X86_64 -headers $INCLUDE "
    XCFRAMEWORK_CREATE+="-library $IPHONE_ARM64 -headers $INCLUDE "
    XCFRAMEWORK_CREATE+="-library $IPHONESIMULATOR_ARM64_X86_64 -headers $INCLUDE "
    XCFRAMEWORK_CREATE+="-library $MAC_ARM64_X86_64 -headers $INCLUDE "

    XCFRAMEWORK_CREATE+="-output Libtorrent.xcframework"
    
    echo "create xcframework..."
    $XCFRAMEWORK_CREATE
}

set -e

print_paths

build_openssl_all_sdk_and_archs

build_boost_b2

build_boost_all_sdk_and_archs

build_libtorrent_all_sdk_and_archs

create_xcframework
