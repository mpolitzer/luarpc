local rpc = require"luarpc"

local obj1 = {
	foo = function (a, b, s) return a+b, "alo alo" end,
	boo = function (n)       return n              end,
}
local obj2 = {
	foo = function (a, b, s) return a-b, "tchau" end,
	boo = function (n)       return 1            end
}

rpc.createServant(obj1, "idl_example.lua")
rpc.createServant(obj2, "idl_example.lua")

rpc.waitIncoming()
