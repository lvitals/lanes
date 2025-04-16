-- lanes-3.18.0-0.rockspec
package = "lanes"
version = "3.18.0-0"

source = {
   url = "git+https://github.com/lvitals/lanes",
   tag = "v3.18.0"
}

description = {
   summary = "Multithreading support for Lua",
   detailed = [[
      Lanes is a Lua extension library providing the possibility to run multiple Lua states in parallel.
      It offers a message-passing model between the states (lanes) with Lindas.
   ]],
   homepage = "https://github.com/lvitals/lanes",
   license = "MIT",
   maintainer = "Leandro Vital Catarin <leavitals@gmail.com>"
}

dependencies = {
   "lua >= 5.1, < 5.5"
}

build = {
   type = "make",
   variables = {
      LUA_INCDIR = "$(LUA_INCDIR)",
      LUA_LIBDIR = "$(LUA_LIBDIR)",
      LUA_BINDIR = "$(LUA_BINDIR)",
      
      -- Flags comuns para todas as plataformas
      CFLAGS = "-Wall -fPIC -O2",
      LIBS = "-lpthread -lm"
   },
   
   platforms = {
      unix = {
         variables = {
            CFLAGS = "$(CFLAGS) -DLUA_USE_LINUX",
            LDFLAGS = "-shared"
         }
      },
      macosx = {
         variables = {
            CFLAGS = "$(CFLAGS) -DMACOSX -DLUA_USE_MACOSX",
            LDFLAGS = "-bundle -undefined dynamic_lookup"
         }
      }
   },
   
   install = {
      lua = {
         ["lanes"] = "src/lanes.lua"
      },
      lib = {
         ["lanes/core"] = "lanes/core.so"
      }
   }
}