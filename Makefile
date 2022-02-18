BOOST_BUILD = b2

BOOST_BUILD_JAM = boost-build.jam

BOOST_ROOT = $(CURDIR)/boost

LIBTORRENT_ROOT = $(CURDIR)/libtorrent

.ONESHELL:

all: $(BOOST_BUILD) $(BOOST_BUILD_JAM)
	BOOST_ROOT=$(BOOST_ROOT) ./$(BOOST_BUILD) link=static variant=release toolset=darwin-iphone -q --user-config=user-config.jam
	
$(BOOST_BUILD):
	@./boost/bootstrap.sh

$(BOOST_BUILD_JAM):
	@printf "boost-build %s/tools/build/src ;" $(BOOST_ROOT) > $(BOOST_BUILD_JAM)

test:
	echo $(CURDIR)

clean:
	@echo "clean"

fclean: clean
	rm -f $(BOOST_BUILD)
	rm -f $(BOOST_BUILD_JAM)
	rm -f project-config.jam

re: fclean all

