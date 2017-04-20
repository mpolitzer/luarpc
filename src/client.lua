local rpc   = require"luarpc"

local obj1 = rpc.createProxy("*", 5500, dofile("idl.lua"))
print(obj1:boo(1))
print(obj1:foo(1,2,"x"))

local obj2 = rpc.createProxy("*", 5501, dofile("idl.lua"))
print(obj2:boo(3))
print(obj2:foo(1,2,"x"))

--local socket = require("socket")

--local conn = assert(socket.connect("*", 5500))
--print(conn:send("hello\n"))
--print(conn:send("world\n"))
--
--socket.sleep(3)
--
--print(conn:send("hello\n"))
--print(conn:send("world\n"))

