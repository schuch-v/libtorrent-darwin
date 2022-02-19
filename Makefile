BOOST_ROOT = $(CURDIR)/boost

BOOST_BUILD = $(BOOST_ROOT)/b2

BOOST_BUILD_JAM = boost-build.jam

OPENSSL_ROOT = $(CURDIR)/openssl

OPENSSL_INCLUDE = $(OPENSSL_ROOT)/include

all: libtorrent

libtorrent: openssl boost
	cd libtorrent && BOOST_ROOT=$(BOOST_ROOT) $(BOOST_BUILD) \
	openssl-lib=$(OPENSSL_ROOT) \
	openssl-include=$(OPENSSL_INCLUDE) \
	link=static \
	variant=release \
	toolset=darwin-iphone \
	-q \
	--user-config=../user-config.jam

openssl: export CROSS_TOP=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
openssl: export CROSS_SDK=iPhoneOS.sdk
openssl:
	cd openssl && ./Configure ios-cross no-shared
	make -C openssl

boost: $(BOOST_BUILD)
	cd boost && $(BOOST_BUILD) link=static variant=release toolset=darwin-iphone -q --user-config=../user-config.jam

$(BOOST_BUILD): $(BOOST_BUILD_JAM)
	cd boost && ./bootstrap.sh
	
$(BOOST_BUILD_JAM):
	@printf "boost-build %s/tools/build/src ;" $(BOOST_ROOT) > $(BOOST_BUILD_JAM)
	
clean:
	cd libtorrent && $(BOOST_BUILD) --clean-all toolset=darwin-iphone
	cd boost && $(BOOST_BUILD) --clean-all toolset=darwin-iphone
	make clean -C openssl
	rm -f $(BOOST_BUILD)
	rm -f $(BOOST_BUILD_JAM)

re: clean all

.PHONY: all libtorrent openssl boost clean re
