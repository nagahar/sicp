CC = gcc -Wall -Wextra -Wformat=2 -Wstrict-aliasing=2 -Wcast-qual -Wcast-align -Wconversion -Wfloat-equal -Wpointer-arith -Wswitch-enum
#CC = gcc -Wall -Wextra -Wformat=2 -Wstrict-aliasing=2 -Wcast-qual -Wcast-align -Wconversion -Wfloat-equal -Wpointer-arith -Wswitch-enum -Wwrite-strings
OBJS = main.o eval.o exp.o env.o util.o
EXEC = interpreter

$(EXEC): $(OBJS)
	$(CC) -o $(EXEC) $(OBJS)
.c.o:
	$(CC) -c $<
clean:
	rm $(EXEC) *.o

