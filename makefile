CC = gcc -ansi -pedantic
CFLAGS = -Wall -g
OBJECTS = lex.yy.o y.tab.o tablasimbolos.o tablahash.o

all: $(OBJECTS)
	$(CC) $(CFLAGS) -o alfa $(OBJECTS)
tablasimbolos.o: tablasimbolos.c tablasimbolos.h
	$(CC) $(CFLAGS) -c tablasimbolos.c
tablashash.o: tablashash.c tablashash.h
	$(CC) $(CFLAGS) -c tablashash.c
lex.yy.o: lex.yy.c y.tab.h
	$(CC) $(CFLAGS) -c lex.yy.c
y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -c y.tab.c
lex.yy.c: alfa.l
	$ flex alfa.l
y.tab.h: alfa.y
	$ bison -d -y -v alfa.y
clean:
	rm alfa  y.tab.o lex.yy.o  tablasimbolos.o lex.yy.c y.tab.c y.output y.tab.h