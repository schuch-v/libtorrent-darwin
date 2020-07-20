NAME		=	libtorrent_test

CC		=	clang++

SRC		=	main.mm	\

OBJ		=	$(SRC:.mm=.o)

CXXFLAGS	=	-I../libtorrent/include	\
			-I../boost/		\
			-std=c++14		\
			-Wall			\
			-Wextra

LDFLAGS		=	-L../bin/mac

LDLIBS		=	-ltorrent

%.o		:	%.mm
			$(CC) -o $@ -c $< $(CXXFLAGS)

all		:	$(NAME)

$(NAME)		:	$(OBJ)
			$(CC) -o $(NAME) $(OBJ) $(LDFLAGS) $(LDLIBS) -framework SystemConfiguration -framework CoreFoundation -framework Foundation

clean		:
			rm -f $(OBJ)

fclean		:	clean
			rm -f $(NAME)

re		:	fclean all

.PHONY		:	all	\
			clean	\
			fclean	\
			re	\
