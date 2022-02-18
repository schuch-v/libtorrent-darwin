BOOST_BUILD = b2

#LIBTORRENT_BOOST_BUILD_JAM = libtorrent/boost-build.jam

all: $(BOOST_BUILD)
	./$(BOOST_BUILD) link=static variant=release toolset=darwin-iphone --user-config=user-config.jam
	
$(BOOST_BUILD):
	@./boost/bootstrap.sh


clean:
	@echo "clean"

fclean:
	rm -vf $(BOOST_BUILD)
	rm -vf project-config.jam

