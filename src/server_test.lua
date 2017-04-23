local rpc = require"luarpc"

local obj1 = {
	foo = function (a, b, c) return a+b, c         end,
	bar = function ()                              end,
	boo = function (n)       return 2              end,
}

rpc.createServant(obj1, dofile("idl_test.lua"))

rpc.waitIncoming()
