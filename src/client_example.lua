local rpc   = require"luarpc"
local ip    = "139.82.2.201"

local obj1 = rpc.createProxy(ip, 5500, "idl_example.lua")
--print(obj1:boo(1))
print(obj1:foo(1, 2, 3))

--local obj2 = rpc.createProxy(ip, 5501, "idl_example.lua")
--print(obj2:boo(3))
--print(obj2:foo(1,2,"x"))

--local socket = require("socket")

--local conn = assert(socket.connect("*", 5500))
--print(conn:send("hello\n"))
--print(conn:send("world\n"))
--
--socket.sleep(3)
--
--print(conn:send("hello\n"))
--print(conn:send("world\n"))

