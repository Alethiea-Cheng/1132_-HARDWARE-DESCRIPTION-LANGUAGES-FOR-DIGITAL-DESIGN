CC = gcc
TARGET = ccordic
SRC = ccordic.c
LDFLAGS = -lm

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(SRC) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET)
