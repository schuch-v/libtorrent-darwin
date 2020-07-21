# libtorrent-darwin

This is [libtorrent](https://www.libtorrent.org/) compiled as a static library and bundled into a `.xcframework`

### Compatible with:
- __iOS__ arm64, x86_64 (iOS 11.0+)
- __macOS__ x86_64

### How to compile

Install [`Xcode`](https://apps.apple.com/app/xcode/id497799835).
Then install `CommandLineTools` (`$ xcode-select --install`).
Make sure you have succesfully cloned the two submodules, `boost` and `libtorrent`.
Switch `boost/tools/build` to the branch `develop` because of an [issue](https://trac.macports.org/ticket/60287).
Finally, run `build_libtorrent.sh`.

If everything went well you will now find `libtorrent.xcframework` in the current directory. 

### Credits

[Apple](https://www.apple.com/)
[libtorrent](https://www.libtorrent.org/)
[boost](https://www.boost.org/)
