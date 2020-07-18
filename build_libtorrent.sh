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
echo "💬 build b2"
./bootstrap.sh
echo "💬 b2 build is DONE !"

echo "💬 writing boost-build.jam"
echo "boost-build ${BOOST_BUILD_ROOT}/src ;" > $LIBTORRENT_SWIFT_ROOT/boost-build.jam
echo "💬 writing boost-build.jam DONE !"

# Boost Headers

echo "💬 cd ${BOOST_ROOT}"
cd $BOOST_ROOT

echo "💬 build boost headers for iPhone"
$BOOST_BUILD_PATH headers cxxstd=14 --user-config=../user-config.jam toolset=darwin-iphone
echo "💬 build boost headers for iPhone DONE !"

echo "💬 build boost headers for Simulator"
$BOOST_BUILD_PATH headers cxxstd=14 --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 build boost headers for Simulator DONE !"

# Libtorrent

echo "💬 cd ${LIBTORRENT_ROOT}"
cd $LIBTORRENT_ROOT

echo "💬 build libtorrent for iPhone"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphone
echo "💬 build libtorrent for iPhone DONE !"

echo "💬 build libtorrent for Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 build libtorrent for Simulator DONE !"
