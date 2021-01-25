# the compiler
CC = sac2c

# compiler flags:
CFLAGS  = -ecc -check tc

# the build target executable:
TARGETS = lesson1 lesson2

all: $(TARGETS)

$(TARGETS): %: %.sac
	$(CC) $(CFLAGS) -o $@ $<
