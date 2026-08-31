TARGET = rover
SRC = rover.s
OBJ = rover.o
AS = arm-linux-gnu-as
LD = arm-linux-gnu-ld
GDB = gdb
ASFLAGS = -march=armv7-a --warn -g

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -o $@ $<

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) -o $@ $<

lint:
	$(AS) $(ASFLAGS) -o /dev/null $(SRC)

run: $(TARGET)
	qemu-arm ./$(TARGET)

# Live remote debugging via QEMU's GDB stub
debug: $(TARGET)
	tmux split-window -h 'qemu-arm -g 1234 ./$(TARGET)'
	tmux select-pane -L
	$(GDB) $(TARGET) -ex "target remote :1234"

# Force a core dump on crash and load it post-mortem.
# qemu-arm honors the host's core-dump settings, so ulimit
# has to be raised in THIS shell before it runs. Core files
# land in the CWD by default; override /proc/sys/kernel/core_pattern
# if your system routes cores elsewhere (e.g. systemd-coredump).
core: $(TARGET)
	ulimit -c unlimited && qemu-arm ./$(TARGET) || true
	@ls *.core 1> /dev/null 2>&1 && \
	  $(GDB) -q $(TARGET) $(lastword $(wildcard *.core)) \
	    -ex "bt full" \
	    -ex "info registers" \
	    -ex "info frame" \
	  || echo "No core file produced — did the program actually crash, or exit cleanly?"

clean:
	rm -f $(OBJ) $(TARGET) *.core

.PHONY: all run clean debug lint core
