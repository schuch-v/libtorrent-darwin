#!/bin/sh

LIBTORRENT_SWIFT_ROOT=$(pwd)
LIBTORRENT_ROOT=$LIBTORRENT_SWIFT_ROOT/libtorrent
BOOST_ROOT=$LIBTORRENT_SWIFT_ROOT/boost
BOOST_BUILD_ROOT=$BOOST_ROOT/tools/build/src
BOOST_BUILD_PATH=$BOOST_ROOT/b2
USER_CONFIG_JAM=$LIBTORRENT_SWIFT_ROOT/user-config.jam
TOOLSETS=(
    darwin-iphone_arm64
    darwin-iphonesimulator_arm64
    darwin-iphonesimulator_x86_64
    darwin-appletv_arm64
    darwin-appletvsimulator_x86_64
    darwin-appletvsimulator_arm64
    darwin-mac_x86_64
    darwin-mac_arm64
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
    echo "boost-build ${BOOST_BUILD_ROOT} ;" > $LIBTORRENT_SWIFT_ROOT/boost-build.jam
fi

# libtorrent

echo "💬 moving to ${LIBTORRENT_ROOT}"
cd $LIBTORRENT_ROOT

for TOOLSET in ${TOOLSETS[@]} ; do
    echo "💬 building libtorrent static for ${TOOLSET}"
    $BOOST_BUILD_PATH --user-config=$USER_CONFIG_JAM threading=multi link=static runtime-link=static variant=release toolset=$TOOLSET
    echo "💬 building libtorrent shared for ${TOOLSET}"
    $BOOST_BUILD_PATH --user-config=$USER_CONFIG_JAM threading=multi link=shared runtime-link=shared variant=release toolset=$TOOLSET
done

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
