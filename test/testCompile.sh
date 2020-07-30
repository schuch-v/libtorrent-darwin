#!/bin/sh

CLANG="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
IPHONE_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
IPHONESIMULATOR_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
APPLETV_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/AppleTVOS.platform/Developer/SDKs/AppleTVOS.sdk"
APPLETVSIMULATOR_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/AppleTVSimulator.platform/Developer/SDKs/AppleTVSimulator.sdk"
MAC_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"

INCLUDE_DIR="../bin/headers"
IPHONE_LIBRARY_PATH="../bin/iphone"
IPHONESIMULATOR_LIBRARY_PATH="../bin/iphonesimulator"
APPLETV_LIBRARY_PATH="../bin/appletv"
APPLETVSIMULATOR_LIBRARY_PATH="../bin/appletvsimulator"
MAC_LIBRARY_PATH="../bin/mac"

FLAGS="-std=c++14 -stdlib=libc++ -framework CoreFoundation -framework SystemConfiguration"

mkdir -p bin

# Static
$CLANG $FLAGS -isysroot $IPHONE_SDK           -arch arm64  -I../bin/headers -ltorrent -L../bin/iphone/static           -o bin/test-static-iphone           main.mm
$CLANG $FLAGS -isysroot $IPHONESIMULATOR_SDK  -arch x86_64 -I../bin/headers -ltorrent -L../bin/iphonesimulator/static  -o bin/test-static-iphonesimulator  main.mm
$CLANG $FLAGS -isysroot $APPLETV_SDK          -arch arm64  -I../bin/headers -ltorrent -L../bin/appletv/static          -o bin/test-static-appletv          main.mm
$CLANG $FLAGS -isysroot $APPLETVSIMULATOR_SDK -arch x86_64 -I../bin/headers -ltorrent -L../bin/appletvsimulator/static -o bin/test-static-appletvsimulator main.mm
$CLANG $FLAGS -isysroot $MAC_SDK              -arch x86_64 -I../bin/headers -ltorrent -L../bin/mac/static              -o bin/test-static-mac              main.mm

# Shared
# To run theses binary you need to set DYLD_LIBRARY_PATH to the correct path (mac example: DYLD_LIBRARY_PATH="../../bin/mac/shared" ./test-shared-mac)
# And obviously you can run theses binaries only on their respective platform
$CLANG $FLAGS -isysroot $IPHONE_SDK           -arch arm64  -I../bin/headers -ltorrent -L../bin/iphone/shared           -o bin/test-shared-iphone           main.mm
$CLANG $FLAGS -isysroot $IPHONESIMULATOR_SDK  -arch x86_64 -I../bin/headers -ltorrent -L../bin/iphonesimulator/shared  -o bin/test-shared-iphonesimulator  main.mm
$CLANG $FLAGS -isysroot $APPLETV_SDK          -arch arm64  -I../bin/headers -ltorrent -L../bin/appletv/shared          -o bin/test-shared-appletv          main.mm
$CLANG $FLAGS -isysroot $APPLETVSIMULATOR_SDK -arch x86_64 -I../bin/headers -ltorrent -L../bin/appletvsimulator/shared -o bin/test-shared-appletvsimulator main.mm
$CLANG $FLAGS -isysroot $MAC_SDK              -arch x86_64 -I../bin/headers -ltorrent -L../bin/mac/shared              -o bin/test-shared-mac              main.mm
