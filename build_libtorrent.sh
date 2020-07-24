#!/bin/sh

LIBTORRENT_SWIFT_ROOT=$(pwd)
LIBTORRENT_ROOT=$LIBTORRENT_SWIFT_ROOT/libtorrent
BOOST_ROOT=$LIBTORRENT_SWIFT_ROOT/boost
BOOST_BUILD_ROOT=$BOOST_ROOT/tools/build
BOOST_BUILD_PATH=$BOOST_BUILD_ROOT/b2

export BOOST_ROOT
export BOOST_BUILD_PATH

# Set bash script to exit immediately if any commands fail.
set -e

# Boost Build

echo "💬 cd ${BOOST_BUILD_ROOT}"
cd $BOOST_BUILD_ROOT
echo "💬 building b2"
./bootstrap.sh --with-toolset=clang
echo "💬 building b2 is DONE !"
echo "💬 writing boost-build.jam"
echo "boost-build ${BOOST_BUILD_ROOT}/src ;" > $LIBTORRENT_SWIFT_ROOT/boost-build.jam
echo "💬 writing boost-build.jam DONE !"

# Libtorrent

echo "💬 cd ${LIBTORRENT_ROOT}"
cd $LIBTORRENT_ROOT

echo "💬 building libtorrent static for iPhone"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphone instruction-set=arm64
echo "💬 building libtorrent static for iPhone DONE !"

echo "💬 building libtorrent dynamic for iPhone"
$BOOST_BUILD_PATH cxxstd=14 link=shared --user-config=../user-config.jam toolset=darwin-iphone instruction-set=arm64
echo "💬 building libtorrent dynamic for iPhone DONE !"

echo "💬 building libtorrent static for Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 building libtorrent static for Simulator DONE !"

echo "💬 building libtorrent dynamic for Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=shared --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 building libtorrent dynamic for Simulator DONE !"

echo "💬 building libtorrent static for Mac"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-mac
echo "💬 building libtorrent static for Mac DONE !"

echo "💬 building libtorrent dynamic for Mac"
$BOOST_BUILD_PATH cxxstd=14 link=shared --user-config=../user-config.jam toolset=darwin-mac
echo "💬 building libtorrent dynamic for Mac DONE !"

echo "💬 Copying build"
cd $LIBTORRENT_SWIFT_ROOT
mkdir -p bin/iphone bin/iphonesimulator bin/mac
cp libtorrent/bin/darwin-iphone/debug/cxxstd-14-iso/instruction-set-arm64/link-static/threading-multi/libtorrent.a bin/iphone
cp libtorrent/bin/darwin-iphone/debug/cxxstd-14-iso/instruction-set-arm64/threading-multi/libtorrent.dylib.1.2.7 bin/iphone
cp libtorrent/bin/darwin-iphonesimulator/debug/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/iphonesimulator
cp libtorrent/bin/darwin-iphonesimulator/debug/cxxstd-14-iso/threading-multi/libtorrent.dylib.1.2.7 bin/iphonesimulator
cp libtorrent/bin/darwin-mac/debug/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/mac
cp libtorrent/bin/darwin-mac/debug/cxxstd-14-iso/threading-multi/libtorrent.dylib.1.2.7 bin/mac
cp boost/bin.v2/libs/system/build/darwin-iphone/debug/cxxstd-14-iso/instruction-set-arm64/threading-multi/visibility-hidden/libboost_system.dylib bin/iphone
cp boost/bin.v2/libs/system/build/darwin-iphonesimulator/debug/cxxstd-14-iso/threading-multi/visibility-hidden/libboost_system.dylib bin/iphonesimulator
cp boost/bin.v2/libs/system/build/darwin-mac/debug/cxxstd-14-iso/threading-multi/visibility-hidden/libboost_system.dylib bin/mac
echo "💬 Copying build DONE !"

echo "💬 Copying headers !"
mkdir -p bin/headers
cp -r boost/boost bin/headers
cp -r libtorrent/include/libtorrent bin/headers
echo "💬 Copying headers DONE !"

echo "💬 Building XCFramework"
mkdir -p bin/framework/static
xcodebuild -create-xcframework -library bin/iphone/libtorrent.a -headers bin/headers -library bin/iphonesimulator/libtorrent.a -headers bin/headers -library bin/mac/libtorrent.a -headers bin/headers -output bin/framework/static/libtorrent.xcframework
echo "💬 Building static XCFramework DONE !"
