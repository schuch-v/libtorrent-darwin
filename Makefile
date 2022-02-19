
BOOST_ROOT = $(CURDIR)/boost
BOOST_BUILD = $(BOOST_ROOT)/b2
BOOST_BUILD_JAM = boost-build.jam

OPENSSL_ROOT = $(CURDIR)/openssl
OPENSSL_INCLUDE = $(OPENSSL_ROOT)/include

openssl: export CROSS_TOP=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
openssl: export CROSS_SDK=iPhoneOS.sdk
openssl:
	cd openssl && ./Configure ios-cross no-shared
	make -C openssl

TOOLSETS = \
	clang-iphone_arm64 \
	clang-iphonesimulator_arm64 \
	clang-iphonesimulator_x86_64 \
	clang-appletv_arm64 \
	clang-appletvsimulator_arm64 \
	clang-appletvsimulator_x86_64 \
	clang-mac_arm64 \
	clang-mac_x86_64 \

# B2

$(BOOST_BUILD): $(BOOST_BUILD_JAM)
	cd boost && ./bootstrap.sh
	
$(BOOST_BUILD_JAM):
	@printf "boost-build %s/tools/build/src ;" $(BOOST_ROOT) > $(BOOST_BUILD_JAM)

# Boost

BUILD_BOOST = \
	cd $(BOOST_ROOT) && \
	$(BOOST_BUILD) \
	--user-config=../user-config.jam \
	link=static \
	variant=release \

boost: $(BOOST_BUILD)
	$(foreach TOOLSET, $(TOOLSETS), $(BUILD_BOOST) toolset=$(TOOLSET) ;)

# Libtorrent

BUILD_LIBTORRENT = \
	cd libtorrent && \
	BOOST_ROOT=$(BOOST_ROOT) $(BOOST_BUILD) \
	-q --user-config=../user-config.jam \
	openssl-lib=$(OPENSSL_ROOT) \
	openssl-include=$(OPENSSL_INCLUDE) \
	link=static \
	variant=release \

libtorrent: openssl boost
	@$(foreach TOOLSET, $(TOOLSETS), $(BUILD_LIBTORRENT) toolset=$(TOOLSET) ;)


	
clean:
	cd libtorrent && $(BOOST_BUILD) --clean-all toolset=darwin-iphone
	cd boost && $(BOOST_BUILD) --clean-all toolset=darwin-iphone
	make clean -C openssl
	rm -f $(BOOST_BUILD)
	rm -f $(BOOST_BUILD_JAM)

re: clean all

.PHONY: all libtorrent openssl boost clean re
