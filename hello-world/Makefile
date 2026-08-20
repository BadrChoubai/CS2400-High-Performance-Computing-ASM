TARGET = hello
SRC = hello.s
OBJ = hello.o

AS = arm-linux-gnu-as
LD = arm-linux-gnu-ld

ASFLAGS = -march=armv7-a

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -o $@ $<

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) -o $@ $<

run: $(TARGET)
	qemu-arm ./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)

.PHONY: all run clean

