#!/bin/sh

# boost/tools/build -> develop branch

LIBTORRENT_ROOT=$(pwd)/libtorrent
BOOST_ROOT=$(pwd)/boost
BOOST_BUILD_ROOT=$BOOST_ROOT/tools/build
BOOST_BUILD_PATH=$BOOST_BUILD_ROOT/b2

export BOOST_ROOT
export BOOST_BUILD_PATH

# Build boost-build
cd $BOOST_BUILD_ROOT
./bootstrap.sh

cd $BOOST_ROOT
$BOOST_BUILD_PATH

# Build libtorrent
cd $LIBTORRENT_ROOT
$BOOST_BUILD_PATH cxxstd=14 --user-config=../user-config.jam toolset=iphone
