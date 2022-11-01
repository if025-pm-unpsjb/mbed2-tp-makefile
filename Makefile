#
# Modify example to build in Makefile.mine
#
-include Makefile.mine

# -------- Include config.mk file fom project --------------------------
include ./apps/$(PROJ)/config.mk
# ----------------------------------------------------------------------

BUILD_DIR = ./build

BIN_NAME = $(TARGET)-$(PROJ_NAME)

MODULES=$(sort $(dir $(wildcard ./libs/*/)))

PROJ_PATH=./apps/$(PROJ)/

TARGET_PATH=./target/$(TARGET)/

###############################################################################
#
# Source code.
#
SRC=$(wildcard ./apps/$(PROJ)/*.c)
CXXSRC=$(wildcard ./apps/$(PROJ)/*.cpp)
OBJECTS += $(CXXSRC:%.cpp=%.o) $(SRC:%.c=%.o)

INCLUDE_PATHS += -I./
INCLUDE_PATHS += $(foreach m, $(MODULES), -I$(m)/inc) 
INCLUDE_PATHS += -I$(PROJ_PATH)/inc 
INCLUDE_PATHS += -I$(PROJ_PATH)/ $(INCLUDES)

###############################################################################
#
# Flags and symbols required for debugging.
#
ifeq ($(DEBUG), y)
  COMMON_FLAGS += -DDEBUG
  COMMON_FLAGS += -Og
  COMMON_FLAGS += -ggdb3
else
  COMMON_FLAGS += -DNDEBUG
  COMMON_FLAGS += -Os
endif

############################################################################### 
GCC_BIN =
AS      = $(GCC_BIN)arm-none-eabi-as
CC      = $(GCC_BIN)arm-none-eabi-gcc
CPP     = $(GCC_BIN)arm-none-eabi-g++
LD      = $(GCC_BIN)arm-none-eabi-gcc
OBJCOPY = $(GCC_BIN)arm-none-eabi-objcopy
SIZE    = $(GCC_BIN)arm-none-eabi-size

###############################################################################
#
# Include module's Makefiles.
#
-include $(foreach m, $(MODULES), $(wildcard $(m)/module.mk))

###############################################################################
#
# Include target Makefile.
#
-include $(TARGET_PATH)/module.mk

###############################################################################
#
# Rules to build the example programs.
#
all: $(BUILD_DIR)/$(BIN_NAME).bin size

clean:
	+@echo "Cleaning files..."	
	@rm -f $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(BIN_NAME).elf $(OBJECTS) $(DEPS)

.c.o:
	+@echo "CC: $<"
	@$(CC)  $(COMMON_FLAGS) $(C_COMMON_FLAGS) $(CC_SYMBOLS) $(INCLUDE_PATHS) -o $@ $<	

.cpp.o:
	+@echo "CC: $<"
	@$(CPP) $(COMMON_FLAGS) $(CPP_COMMON_FLAGS) $(CC_SYMBOLS) $(INCLUDE_PATHS) -g -o $@ $<	

$(BUILD_DIR)/$(BIN_NAME).elf: $(OBJECTS) $(SYS_OBJECTS)
	+@echo "Linking: $@"
	@$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ $(LIBRARIES) $(LD_SYS_LIBS)

$(BUILD_DIR)/$(BIN_NAME).bin: $(BUILD_DIR)/$(BIN_NAME).elf
	+@echo "Binary: $@"	
	@$(OBJCOPY) -O binary $< $@
	
size: $(BUILD_DIR)/$(BIN_NAME).elf
	$(SIZE) $<

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)
