CFLAGS = -I/opt/homebrew/include/lua -I../src/ -DMACOSX -DLUA_USE_MACOSX -fPIC
LDFLAGS = -L/opt/homebrew/lib -llua -shared -undefined dynamic_lookup

all: deep_test.so

deep_test.so: deep_test.c ../src/*.c
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	rm -f deep_test.so
