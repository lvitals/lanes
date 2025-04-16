#include <string.h>
#include <assert.h>

#include "universe.h"
#include "compat.h"
#include "macros_and_utils.h"
#include "uniquekey.h"

// crc64/we of string "UNIVERSE_REGKEY" generated at http://www.nitrxgen.net/hashgen/
static DECLARE_CONST_UNIQUE_KEY(UNIVERSE_REGKEY, 0x9f877b2cf078f17f);

Universe *universe_create(lua_State *L)
{
    Universe *U = (Universe *)lua_newuserdatauv(L, sizeof(Universe), 0); // universe
    memset(U, 0, sizeof(Universe));
    STACK_CHECK(L, 1);
    REGISTRY_SET(L, UNIVERSE_REGKEY, lua_pushvalue(L, -2)); // universe
    STACK_END(L, 1);
    return U;
}

void universe_store(lua_State *L, Universe *U)
{
    STACK_CHECK(L, 0);
    REGISTRY_SET(L, UNIVERSE_REGKEY, (NULL != U) ? lua_pushlightuserdata(L, U) : lua_pushnil(L));
    STACK_END(L, 0);
}

Universe *universe_get(lua_State *L)
{
    Universe *universe;
    STACK_GROW(L, 2);
    STACK_CHECK(L, 0);
    REGISTRY_GET(L, UNIVERSE_REGKEY);
    universe = lua_touserdata(L, -1); // NULL if nil
    lua_pop(L, 1);
    STACK_END(L, 0);
    return universe;
}
