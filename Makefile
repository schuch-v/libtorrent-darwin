BOOST_ROOT = $(CURDIR)/boost

BOOST_BUILD = $(BOOST_ROOT)/b2

BOOST_BUILD_JAM = boost-build.jam

all: openssl libtorrent

libtorrent: $(BOOST_BUILD) $(BOOST_BUILD_JAM)
	BOOST_ROOT=$(BOOST_ROOT) $(BOOST_BUILD) link=static variant=release toolset=darwin-iphone -q --user-config=user-config.jam
	
$(BOOST_BUILD):
	cd boost && ./bootstrap.sh

$(BOOST_BUILD_JAM):
	@printf "boost-build %s/tools/build/src ;" $(BOOST_ROOT) > $(BOOST_BUILD_JAM)

openssl: export CROSS_TOP=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
openssl: export CROSS_SDK=iPhoneOS.sdk
openssl:
	cd openssl && ./Configure ios-cross no-shared
	make -C openssl
	
clean:
	rm -f $(BOOST_BUILD)
	rm -f $(BOOST_BUILD_JAM)
	rm -f project-config.jam
	make clean -C openssl

re: clean all

.PHONY: all libtorrent openssl clean re
