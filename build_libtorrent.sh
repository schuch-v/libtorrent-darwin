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

# iPhone

echo "💬 building libtorrent static for iPhone"
$BOOST_BUILD_PATH cxxstd=14 link=static variant=release --user-config=../user-config.jam toolset=darwin-iphone instruction-set=arm64
echo "💬 building libtorrent static for iPhone DONE !"

echo "💬 building libtorrent shared for iPhone"
$BOOST_BUILD_PATH cxxstd=14 link=shared variant=release --user-config=../user-config.jam toolset=darwin-iphone instruction-set=arm64
echo "💬 building libtorrent shared for iPhone DONE !"

# iPhone Simulator

echo "💬 building libtorrent static for iPhone Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=static variant=release --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 building libtorrent static for iPhone Simulator DONE !"

echo "💬 building libtorrent shared for iPhone Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=shared variant=release --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 building libtorrent shared for iPhone Simulator DONE !"

# AppleTV

echo "💬 building libtorrent static for AppleTV"
$BOOST_BUILD_PATH cxxstd=14 link=static variant=release --user-config=../user-config.jam toolset=darwin-appletv instruction-set=arm64
echo "💬 building libtorrent static for AppleTV DONE !"

echo "💬 building libtorrent shared for AppleTV"
$BOOST_BUILD_PATH cxxstd=14 link=shared variant=release --user-config=../user-config.jam toolset=darwin-appletv instruction-set=arm64
echo "💬 building libtorrent shared for AppleTV DONE !"

# AppleTV Simulator

echo "💬 building libtorrent static for AppleTV Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=static variant=release --user-config=../user-config.jam toolset=darwin-appletvsimulator
echo "💬 building libtorrent static for AppleTV Simulator DONE !"

echo "💬 building libtorrent shared for AppleTV Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=shared variant=release --user-config=../user-config.jam toolset=darwin-appletvsimulator
echo "💬 building libtorrent shared for AppleTV Simulator DONE !"

# Mac

echo "💬 building libtorrent static for Mac"
$BOOST_BUILD_PATH cxxstd=14 link=static variant=release --user-config=../user-config.jam toolset=darwin-mac
echo "💬 building libtorrent static for Mac DONE !"

echo "💬 building libtorrent shared for Mac"
$BOOST_BUILD_PATH cxxstd=14 link=shared variant=release --user-config=../user-config.jam toolset=darwin-mac
echo "💬 building libtorrent shared for Mac DONE !"

echo "💬 Copying build"
cd $LIBTORRENT_SWIFT_ROOT
mkdir -p bin/iphone/{static,shared} bin/iphonesimulator/{static,shared} bin/appletv/{static,shared} bin/appletvsimulator/{static,shared} bin/mac/{static,shared}
cp libtorrent/bin/darwin-iphone/release/cxxstd-14-iso/instruction-set-arm64/link-static/threading-multi/libtorrent.a bin/iphone/static
cp libtorrent/bin/darwin-iphone/release/cxxstd-14-iso/instruction-set-arm64/threading-multi/libtorrent.dylib bin/iphone/shared
cp libtorrent/bin/darwin-iphonesimulator/release/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/iphonesimulator/static
cp libtorrent/bin/darwin-iphonesimulator/release/cxxstd-14-iso/threading-multi/libtorrent.dylib bin/iphonesimulator/shared

cp libtorrent/bin/darwin-appletv/release/cxxstd-14-iso/instruction-set-arm64/link-static/threading-multi/libtorrent.a bin/appletv/static
cp libtorrent/bin/darwin-appletv/release/cxxstd-14-iso/instruction-set-arm64/threading-multi/libtorrent.dylib bin/appletv/shared
cp libtorrent/bin/darwin-appletvsimulator/release/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/appletvsimulator/static
cp libtorrent/bin/darwin-appletvsimulator/release/cxxstd-14-iso/threading-multi/libtorrent.dylib bin/appletvsimulator/shared

cp libtorrent/bin/darwin-mac/release/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/mac/static
cp libtorrent/bin/darwin-mac/release/cxxstd-14-iso/threading-multi/libtorrent.dylib bin/mac/shared

cp boost/bin.v2/libs/system/build/darwin-iphone/release/cxxstd-14-iso/instruction-set-arm64/threading-multi/visibility-hidden/libboost_system.dylib bin/iphone/shared
cp boost/bin.v2/libs/system/build/darwin-iphonesimulator/release/cxxstd-14-iso/threading-multi/visibility-hidden/libboost_system.dylib bin/iphonesimulator/shared
cp boost/bin.v2/libs/system/build/darwin-appletv/release/cxxstd-14-iso/instruction-set-arm64/threading-multi/visibility-hidden/libboost_system.dylib bin/appletv/shared
cp boost/bin.v2/libs/system/build/darwin-appletvsimulator/release/cxxstd-14-iso/threading-multi/visibility-hidden/libboost_system.dylib bin/appletvsimulator/shared
cp boost/bin.v2/libs/system/build/darwin-mac/release/cxxstd-14-iso/threading-multi/visibility-hidden/libboost_system.dylib bin/mac/shared
echo "💬 Copying build DONE !"

echo "💬 Copying headers !"
mkdir -p bin/headers
cp -r boost/boost bin/headers
cp -r libtorrent/include/libtorrent bin/headers
echo "💬 Copying headers DONE !"

echo "💬 Building XCFramework"
mkdir -p bin/framework/static
xcodebuild -create-xcframework \
           -library bin/iphone/static/libtorrent.a -headers bin/headers \
           -library bin/iphonesimulator/static/libtorrent.a -headers bin/headers \
           -library bin/appletv/static/libtorrent.a -headers bin/headers \
           -library bin/appletvsimulator/static/libtorrent.a -headers bin/headers \
           -library bin/mac/static/libtorrent.a -headers bin/headers \
           -output bin/framework/static/LibTorrent.xcframework

cd bin/framework/static/LibTorrent.xcframework
ARCH_DIRS=$(/bin/ls -d */)
cd $LIBTORRENT_SWIFT_ROOT
cp -rf bin/headers bin/framework/static/LibTorrent.xcframework/Headers
cd bin/framework/static/LibTorrent.xcframework
for ARCH_DIR in $ARCH_DIRS;
do
  rm -rf "${ARCH_DIR}/Headers"
  ln -sfh ../Headers "${ARCH_DIR}/Headers"
done
echo "💬 Building static XCFramework DONE !"
