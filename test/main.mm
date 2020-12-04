#include <iostream>
#include <sys/time.h>

@import Foundation;

#include "libtorrent/entry.hpp"
#include "libtorrent/bencode.hpp"
#include "libtorrent/session.hpp"
#include "libtorrent/torrent_info.hpp"
#include "libtorrent/torrent_status.hpp"

int main(int argc, char* argv[])
{
    //NSURL *torrent_url = [NSURL URLWithString:@"https://yts.mx/torrent/download/9BA8EB640F2EB48B1AB2C64DEA8DEDAD5ECD0175"];
    NSURL *torrent_url = [NSURL URLWithString:@"https://webtorrent.io/torrents/sintel.torrent"];
    NSData *torrent_data = [[NSData alloc] initWithContentsOfURL: torrent_url];
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    lt::session s;
    lt::add_torrent_params p;
    
    p.save_path = [documents cStringUsingEncoding:NSASCIIStringEncoding];
    
    lt::error_code ec;
    //p.ti = std::make_shared<lt::torrent_info>(argv[1]);
    p.ti = std::make_shared<lt::torrent_info>((char const *)torrent_data.bytes, (int)torrent_data.length, ec);
    
    lt::torrent_handle handle = s.add_torrent(p);

    for (;;) {
        lt::torrent_status status = handle.status();
        std::cout << status.progress << std::endl;
        
        if (!s.wait_for_alert(lt::milliseconds(1000))) {
            std::cout << "no alerts." << std::endl;
            continue;
        }
        std::vector<lt::alert*> alerts;
        s.pop_alerts(&alerts);
        for (lt::alert const* a : alerts) {
            std::cout << a->message() << std::endl;
        }
    }
}
  
