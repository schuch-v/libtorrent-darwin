Pod::Spec.new do |spec|

  spec.name                   = "LibtorrentDarwin"
  spec.version                = "0.0.1"
  spec.summary                = "libtorrent compiled for Apple Darwin based OSes (iOS, macOs)"
  spec.description            = "libtorrent is an open-source implementation of the BitTorrent protocol."
  spec.homepage               = "https://github.com/schuch-v/libtorrent-darwin"
  spec.license                = "MIT"
  spec.author                 = "Victor"
  spec.ios.deployment_target  = "11.0"
  spec.osx.deployment_target  = "10.10"
  spec.requires_arc           = true
  spec.source                 = { :http => "https://github.com/schuch-v/libtorrent-darwin/releases/download/v1.2.7/libtorrent.xcframework.zip" }
  spec.frameworks             = "CoreFoundation", "SystemConfiguration"
  spec.vendored_frameworks    = "libtorrent.xcframework"
end
