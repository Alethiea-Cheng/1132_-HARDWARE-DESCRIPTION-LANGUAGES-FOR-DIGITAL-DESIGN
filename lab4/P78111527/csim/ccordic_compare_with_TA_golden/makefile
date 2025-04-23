CC = gcc
TARGET = ccordic_compare_with_TA_golden
SRC = $(TARGET).c
LDFLAGS = -lm

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(SRC) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET)
