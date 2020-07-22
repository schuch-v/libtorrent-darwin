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

echo "💬 building boost headers for Mac"
$BOOST_BUILD_PATH headers cxxstd=14 --user-config=../user-config.jam toolset=darwin-mac
echo "💬 building boost headers for Mac DONE !"

# Libtorrent

echo "💬 cd ${LIBTORRENT_ROOT}"
cd $LIBTORRENT_ROOT

echo "💬 building libtorrent for iPhone"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphone
echo "💬 building libtorrent for iPhone DONE !"

echo "💬 building libtorrent for Simulator"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-iphonesimulator
echo "💬 building libtorrent for Simulator DONE !"

echo "💬 building libtorrent for Mac"
$BOOST_BUILD_PATH cxxstd=14 link=static --user-config=../user-config.jam toolset=darwin-mac
echo "💬 building libtorrent for Mac DONE !"

echo "💬 Copying build"
cd $LIBTORRENT_SWIFT_ROOT
mkdir -p bin/iphone bin/iphonesimulator bin/mac
cp libtorrent/bin/darwin-iphone/debug/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/iphone
cp libtorrent/bin/darwin-iphonesimulator/debug/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/iphonesimulator
cp libtorrent/bin/darwin-mac/debug/cxxstd-14-iso/link-static/threading-multi/libtorrent.a bin/mac
echo "💬 Copying build DONE !"

echo "💬 Copying headers !"
mkdir -p bin/headers
cp -r boost/boost bin/headers
cp -r libtorrent/include/libtorrent bin/headers
echo "💬 Copying headers DONE !"

echo "💬 Building static XCFramework"
mkdir -p bin/framework/static
xcodebuild -create-xcframework -library bin/iphone/libtorrent.a -headers bin/headers -library bin/iphonesimulator/libtorrent.a -headers bin/headers -library bin/mac/libtorrent.a -headers bin/headers -output bin/framework/static/libtorrent.xcframework
echo "💬 Building static XCFramework DONE !"

echo "💬 Building dynamic XCFramework"
cd bin/iphone
ar -x libtorrent.a
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++ -arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -shared *.o -o libtorrent.dylib -framework CoreFoundation -framework SystemConfiguration
rm *.o __.SYMDEF
mkdir -p libtorrent.framework/Versions/A/Headers
cp -rf ../headers/* libtorrent.framework/Versions/A/Headers
lipo -create libtorrent.dylib -output libtorrent.framework/Versions/A/libtorrent
ln -sfh A libtorrent.framework/Versions/Current
ln -sfh Versions/Current/Headers libtorrent.framework/Headers
ln -sfh Versions/Current/libtorrent libtorrent.framework/libtorrent

cd ..
cd iphonesimulator
ar -x libtorrent.a
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++ -arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk -shared *.o -o libtorrent.dylib -framework CoreFoundation -framework SystemConfiguration
rm *.o __.SYMDEF
mkdir -p libtorrent.framework/Versions/A/Headers
cp -rf ../headers/* libtorrent.framework/Versions/A/Headers
lipo -create libtorrent.dylib -output libtorrent.framework/Versions/A/libtorrent
ln -sfh A libtorrent.framework/Versions/Current
ln -sfh Versions/Current/Headers libtorrent.framework/Headers
ln -sfh Versions/Current/libtorrent libtorrent.framework/libtorrent

cd ..
cd mac
ar -x libtorrent.a
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++ -arch x86_64 -isysroot  /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -shared *.o -o libtorrent.dylib -framework CoreFoundation -framework SystemConfiguration
rm *.o __.SYMDEF
mkdir -p libtorrent.framework/Versions/A/Headers
cp -rf ../headers/* libtorrent.framework/Versions/A/Headers
lipo -create libtorrent.dylib -output libtorrent.framework/Versions/A/libtorrent
ln -sfh A libtorrent.framework/Versions/Current
ln -sfh Versions/Current/Headers libtorrent.framework/Headers
ln -sfh Versions/Current/libtorrent libtorrent.framework/libtorrent
