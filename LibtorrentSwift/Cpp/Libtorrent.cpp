//
//  Libtorrent.cpp
//  LibtorrentSwift
//
//  Created by Victor Schuchmann on 18/07/2020.
//  Copyright © 2020 Victor Schuchmann. All rights reserved.
//

#include <cstdlib>
#include "libtorrent/entry.hpp"
#include "libtorrent/bencode.hpp"
#include "libtorrent/session.hpp"
#include "libtorrent/torrent_info.hpp"

#include <iostream>

#include "Libtorrent.hpp"

void hello_world()
{
    char *torrent = strdup("lol");
    
    lt::session s;
    lt::add_torrent_params p;
    p.save_path = "./";
    p.ti = std::make_shared<lt::torrent_info>(torrent);
    s.add_torrent(p);
    
    // wait for the user to end
    char a;
    int ret = std::scanf("%c\n", &a);
    (void)ret; // ignore
    free(torrent);
}
