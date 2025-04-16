# Generic Makefile for Lanes Lua library
# Auto-detects Lua version and paths across different systems

# Detect the operating system
UNAME_S := $(shell uname -s)

# Common compiler flags
CFLAGS = -Wall -fPIC -O2
LIBS = -lpthread -lm

# Try to detect Lua version and paths
LUA_VERSION ?= $(shell lua -e "print(string.sub(_VERSION, 5))" 2>/dev/null || echo "5.4")
LUA_INC ?= $(shell pkg-config --variable=includedir lua$(LUA_VERSION) 2>/dev/null || \
             echo "/usr/local/include/lua$(LUA_VERSION)" || \
             echo "/usr/include/lua$(LUA_VERSION)")
LUA_LIB ?= $(shell pkg-config --variable=libdir lua$(LUA_VERSION) 2>/dev/null || \
             echo "/usr/local/lib" || \
             echo "/usr/lib")

# Platform-specific adjustments
ifeq ($(UNAME_S),Darwin)
  # macOS settings
  CFLAGS += -DMACOSX -DLUA_USE_MACOSX
  LDFLAGS = -bundle -undefined dynamic_lookup
  # Homebrew paths
  ifeq ($(wildcard $(LUA_INC)),)
    LUA_INC := /opt/homebrew/include/lua$(LUA_VERSION)
    LUA_LIB := /opt/homebrew/lib
  endif
  # Installation paths for macOS
  INSTALL_LIB_DIR := /opt/homebrew/lib/lua/$(LUA_VERSION)/lanes
else
  # Linux settings
  CFLAGS += -DLUA_USE_LINUX
  LDFLAGS = -shared
  INSTALL_LIB_DIR ?= $(shell pkg-config --variable=INSTALL_LIB lua$(LUA_VERSION) 2>/dev/null || \
                    echo "/usr/local/lib/lua/$(LUA_VERSION)/lanes" || \
                    echo "/usr/lib/lua/$(LUA_VERSION)/lanes")
endif

# Version-specific defines
CFLAGS += -DLUA_VERSION_$(subst .,_,$(LUA_VERSION))

# Source directory
SRC_DIR = src

# Source files
SRCS = $(SRC_DIR)/lanes.c $(SRC_DIR)/cancel.c $(SRC_DIR)/compat.c \
       $(SRC_DIR)/threading.c $(SRC_DIR)/tools.c $(SRC_DIR)/state.c \
       $(SRC_DIR)/linda.c $(SRC_DIR)/deep.c $(SRC_DIR)/keeper.c \
       $(SRC_DIR)/universe.c
OBJS = $(patsubst $(SRC_DIR)/%.c,$(SRC_DIR)/%.o,$(SRCS))
TARGET = lanes/core.so

all: $(SRC_DIR) $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p lanes
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS) -L$(LUA_LIB) -llua$(LUA_VERSION)

$(SRC_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -I$(LUA_INC) -c -o $@ $<

clean:
	rm -f $(SRC_DIR)/*.o $(TARGET)

install: $(TARGET)
	@echo "Installing to $(INSTALL_LIB_DIR)"
	@mkdir -p "$(INSTALL_LIB_DIR)"
	@cp $(TARGET) "$(INSTALL_LIB_DIR)/"
	@echo "Successfully installed"

uninstall:
	@if [ -f "$(INSTALL_LIB_DIR)/core.so" ]; then \
		echo "Removing $(INSTALL_LIB_DIR)/core.so"; \
		rm -f "$(INSTALL_LIB_DIR)/core.so"; \
		if [ -d "$(INSTALL_LIB_DIR)" ] && [ -z "$$(ls -A $(INSTALL_LIB_DIR))" ]; then \
			echo "Removing empty directory $(INSTALL_LIB_DIR)"; \
			rmdir "$(INSTALL_LIB_DIR)"; \
		fi; \
		echo "Successfully uninstalled"; \
	else \
		echo "Error: $(INSTALL_LIB_DIR)/core.so not found"; \
		exit 1; \
	fi

print-config:
	@echo "Detected configuration:"
	@echo "  OS: $(UNAME_S)"
	@echo "  Lua version: $(LUA_VERSION)"
	@echo "  Lua includes: $(LUA_INC)"
	@echo "  Lua library path: $(LUA_LIB)"
	@echo "  Install path: $(INSTALL_LIB_DIR)"

.PHONY: all clean install uninstall print-config