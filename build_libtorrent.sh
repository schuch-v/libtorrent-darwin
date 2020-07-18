#!/bin/sh

LIBTORRENT_SWIFT_ROOT=$(pwd)
LIBTORRENT_ROOT=$LIBTORRENT_SWIFT_ROOT/libtorrent
BOOST_ROOT=$LIBTORRENT_SWIFT_ROOT/boost
BOOST_BUILD_ROOT=$BOOST_ROOT/tools/build
BOOST_BUILD_PATH=$BOOST_BUILD_ROOT/b2

export BOOST_ROOT
export BOOST_BUILD_PATH

# Boost Build

echo "💬 cd ${BOOST_BUILD_ROOT}"
cd $BOOST_BUILD_ROOT
echo "💬 building b2"
./bootstrap.sh
echo "💬 building b2 is DONE !"

echo "💬 writing boost-build.jam"
echo "boost-build ${BOOST_BUILD_ROOT}/src ;" > $LIBTORRENT_SWIFT_ROOT/boost-build.jam
echo "💬 writing boost-build.jam DONE !"

# Boost Headers

echo "💬 cd ${BOOST_ROOT}"
cd $BOOST_ROOT

echo "💬 building boost headers for iPhone"
$BOOST_BUILD_PATH headers cxxstd=14 --user-config=../user-config.jam toolset=darwin-iphone
echo "💬 building boost headers for iPhone DONE !"

echo "💬 building boost headers for Simulator"
$BOOST_BUILD_PATH headers cxxstd=14 --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 building boost headers for Simulator DONE !"

# Libtorrent

echo "💬 cd ${LIBTORRENT_ROOT}"
cd $LIBTORRENT_ROOT

echo "💬 building libtorrent for iPhone"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphone
echo "💬 building libtorrent for iPhone DONE !"

echo "💬 building libtorrent for Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 building libtorrent for Simulator DONE !"

echo "💬 Copying build"
cd $LIBTORRENT_SWIFT_ROOT
mkdir -p bin/iphone bin/iphonesimulator bin/universal
cp libtorrent/bin/darwin-iphone/debug/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/iphone
cp libtorrent/bin/darwin-iphonesimulator/debug/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/iphonesimulator
echo "💬 Copying build DONE !"

echo "💬 Creating universal binary"
lipo -create bin/iphone/libtorrent.a bin/iphonesimulator/libtorrent.a -output bin/universal/libtorrent.a
echo "💬 Creating universal binary DONE !"
