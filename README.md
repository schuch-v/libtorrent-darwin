# libtorrent-darwin

This is [libtorrent](https://www.libtorrent.org/) compiled as a static library and bundled into a `.xcframework`

### Compatible with:
- __iOS__ arm64, x86_64 (iOS 11.0+)
- __macOS__ x86_64

### Work arounds

The latest version of Boost have an [issue](https://trac.macports.org/ticket/60287) on macOS, for now, you can switch `boost/tools/build` to the `develop` branch.
To be able to compile Boost for `arm64` i had to found a way to prevent `b2` from linking with `-arch armv4t`, because otherwise `ld` would gave the error `ld: unknown/unsupported architecture name for: -arch armv4t`
So i modified Boost build to accept `arm64` as an `instruction-set`. this is not the prettiest solution because now `b2` add two times the flag `-arch arm64` but hey at least it compiles !
Just add `arm64` to the list in the file `boost/tools/build/src/tools/features/instruction-set-feature.jam`

### How to compile

Install [`Xcode`](https://apps.apple.com/app/xcode/id497799835).
Then install `CommandLineTools` (`$ xcode-select --install`).
Make sure you have succesfully cloned the two submodules, `boost` and `libtorrent`.
Finally, run `build_libtorrent.sh`.

If everything went well you will now find `libtorrent.xcframework` in `bin/framework`. 

### CocoaPods

as of right now cocoapod does not support vendored `.xcframework` containing static libs, (see issue [here](https://github.com/CocoaPods/CocoaPods/issues/9528))

### Credits

[Apple](https://www.apple.com/)
[libtorrent](https://www.libtorrent.org/)
[boost](https://www.boost.org/)
