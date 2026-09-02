TARGET = mars_mission
SRC = mars_mission.s
OBJ = mars_mission.o
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
QEMU_SESSION = $(TARGET)-qemu
GDB_SESSION  = $(TARGET)-gdb

# Runs qemu (with GDB stub) and GDB in two independent tmux sessions.
debug: $(TARGET)
	tmux kill-session -t $(QEMU_SESSION) 2>/dev/null || true
	tmux kill-session -t $(GDB_SESSION) 2>/dev/null || true
	tmux new-session -d -s $(QEMU_SESSION) 'qemu-arm -g 1234 ./$(TARGET)'
	tmux new-session -d -s $(GDB_SESSION) \
		'$(GDB) $(TARGET) -ex "target remote :1234"'
	@if [ -n "$$TMUX" ]; then \
		tmux switch-client -t $(GDB_SESSION); \
	else \
		tmux attach-session -t $(GDB_SESSION); \
	fi

# Tear down both sessions at once.
debug-stop:
	tmux kill-session -t $(QEMU_SESSION) 2>/dev/null || true
	tmux kill-session -t $(GDB_SESSION) 2>/dev/null || true

clean:
	rm -f $(OBJ) $(TARGET) *.core

.PHONY: all run clean debug debug-stop lint
