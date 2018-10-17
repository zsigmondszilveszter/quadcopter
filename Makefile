# headers location
IDIR =includes
CC=gcc
CFLAGS=-I$(IDIR)
LIBS=-pthread

# source files location
SDIR=src
# store object files in this directory
ODIR=$(SDIR)/obj
# location for library functions
LDIR =$(SDIR)/lib

_DEPS = tcpSocket.h threadManager.h szilv_i2c.h itg3200_gyro.h mag3110_magnm.h lsm6ds33.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = main.o tcpWrapper.o threadManager.o szilv_i2c.o itg3200_gyro.o mag3110_magnm.o lsm6ds33.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

# every object file depends on the certain .c file and the header files too
$(ODIR)/%.o: $(SDIR)/%.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS) $(LIBS)

# networking directory
$(ODIR)/%.o: $(SDIR)/networking/%.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS) $(LIBS)

# sensors directory
$(ODIR)/%.o: $(SDIR)/sensors/%.c $(DEPS)
	$(CC) -O -c -o $@ $< $(CFLAGS) $(LIBS)

# library directory
$(ODIR)/%.o: $(SDIR)/library/%.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS) $(LIBS)

# the first and default make rule, this links the object files and builds the ELF file with the name of the rule
dev: $(OBJ)
	$(CC) -o qc_server_$@ $^ $(CFLAGS) $(LIBS)

# production build
prod: $(OBJ)
	$(CC) -O2 -o qc_server_$@ $^ $(CFLAGS) $(LIBS)

.PHONY: clean

# clean the project directory from the object files and temporary stuffs
clean:
	rm -f $(ODIR)/*.o $(SDIR)/*~ core $(IDIR)/*~
	rm -f qc_server_*