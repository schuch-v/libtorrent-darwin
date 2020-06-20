#!/bin/sh

LIBTORRENT_ROOT=$(pwd)/libtorrent
BOOST_ROOT=$(pwd)/boost
BOOST_BUILD_ROOT=$BOOST_ROOT/tools/build
BOOST_BUILD_PATH=$BOOST_BUILD_ROOT/b2

export BOOST_ROOT
export BOOST_BUILD_PATH

cd $BOOST_BUILD_ROOT
./bootstrap.sh

cd $BOOST_ROOT
$BOOST_BUILD_PATH headers

# Build libtorrent
cd $LIBTORRENT_ROOT
$BOOST_BUILD_PATH $BOOST_BUILD_TOOLSET_IPHONE cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphone
$BOOST_BUILD_PATH $BOOST_BUILD_TOOLSET_SIMULATOR cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphonesimulator
