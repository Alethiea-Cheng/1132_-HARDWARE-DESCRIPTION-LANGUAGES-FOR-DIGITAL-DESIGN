CC = gcc
TARGET = arctan_table
SRC = arctan_table.c
LDFLAGS = -lm

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(SRC) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET)
