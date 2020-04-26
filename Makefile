# source files location
SDIR=src
# headers location
IDIR =$(SDIR)/includes
IDIR_LIBRARY=$(IDIR)/library
IDIR_SENSORS=$(SDIR)/sensors
IDIR_NETWORKING=$(IDIR)/networking
IDIR_TIMING=$(IDIR)/timing
CC=gcc
MKDIR=mkdir
CFLAGS=-I$(IDIR) -I$(IDIR_NETWORKING) -I$(IDIR_LIBRARY) -I$(IDIR_TIMING) -I$(IDIR_SENSORS) -lm -lrt
LIBS=-pthread

# store object files in this directory
ODIR=$(SDIR)/obj
# location for library functions
LDIR =$(SDIR)/lib

#
_SENSOR_OBJECTS = pololu_imu_v5.o lsm6ds33.o lis3mdl.o bmp180.o
_OBJ = main.o tcpWrapper.o threadManager.o szilv_i2c.o tools.o state_machine.o intervalTimer.o $(_SENSOR_OBJECTS)
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

# networking directory
_NETWORKING_HEADERS = tcpWrapper.h
NETWORKING_HEADERS_DEPS = $(patsubst %,$(IDIR)/networking/%,$(_NETWORKING_HEADERS))
$(ODIR)/%.o: $(SDIR)/networking/%.c $(NETWORKING_HEADERS_DEPS)
	$(CC) -O2 -c -o $@ $< $(CFLAGS) $(LIBS)

# pololu imu sensors headers
_POLOLU_SENSOR_HEADERS = pololu_imu_v5.h lsm6ds33.h lis3mdl.h
POLOLU_SENSOR_HEADERS_DEPS = $(patsubst %,$(SDIR)/sensors/pololu_imu_v5/%,$(_POLOLU_SENSOR_HEADERS))
# pololu sensors directory
$(ODIR)/%.o: $(SDIR)/sensors/pololu_imu_v5/%.c $(POLOLU_SENSOR_HEADERS_DEPS)
	$(CC) -O2 -c -o $@ $< $(CFLAGS) $(LIBS)

$(ODIR)/%.o: $(SDIR)/sensors/bmp180/%.c $(SDIR)/sensors/bmp180/bmp180.h
	$(CC) -O2 -c -o $@ $< $(CFLAGS) $(LIBS)

# library directory
_LIBRARY_HEADERS = tools.h szilv_i2c.h threadManager.h
LIBRARY_HEADERS_DEPS = $(patsubst %,$(IDIR)/library/%,$(_LIBRARY_HEADERS))
$(ODIR)/%.o: $(SDIR)/library/%.c $(LIBRARY_HEADERS_DEPS)
	$(CC) -O2 -c -o $@ $< $(CFLAGS) $(LIBS)

# timing directory
_TIMING_HEADERS = intervalTimer.h
TIMING_HEADERS_DEPS = $(patsubst %,$(IDIR)/timing/%,$(_TIMING_HEADERS))
$(ODIR)/%.o: $(SDIR)/timing/%.c $(TIMING_HEADERS_DEPS)
	$(CC) -O2 -c -o $@ $< $(CFLAGS) $(LIBS) 


_HEADERS = state_machine.h
HEADERS_DEPS = $(patsubst %,$(IDIR)/%,$(_HEADERS))
# every object file depends on the certain .c file and the certain header files too
$(ODIR)/%.o: $(SDIR)/%.c $(HEADERS_DEPS)
	$(CC) -O2 -c -o $@ $< $(CFLAGS) $(LIBS)

#
$(OBJ): | CreateObjDir

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

.PHONY: CreateObjDir
# create object directory if it doesn't exist
CreateObjDir:
	@$(MKDIR) -p $(ODIR)
