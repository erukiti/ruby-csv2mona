CFLAGS += -Wall -Wpointer-arith -Wshadow -O --input-charset=cp932 --exec-charset=cp932
CFLAGS += -mno-cygwin -mwindows

all: width.dat

width.dat: mkwidth.exe
	./mkwidth.exe > width.dat

mkwidth.exe: mkwidth.c
	$(CC) $(CFLAGS) -o mkwidth.exe mkwidth.c
