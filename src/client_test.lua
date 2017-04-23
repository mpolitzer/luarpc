local socket = require "socket"
local rpc = require "luarpc"

local obj1 = rpc.createProxy("*", 5500, dofile("idl_test.lua"))

print("Execução de foo 10000x")
local a, b
local start_time = socket.gettime()
for i = 1,10000 do
  a, b = obj1:foo(1, 2, 3)
end
print("Duração: "..socket.gettime() - start_time)
assert(a, 3)
assert(b, 3)

print("")

print("Execução de bar 10000x")
start_time = socket.gettime()
for i = 1,10000 do
  a = obj1:bar()
end
print("Duração: "..socket.gettime() - start_time)
assert(not a)

print("")

print("Execução de boo 10000x com uma string pequena")
start_time = socket.gettime()
for i = 1,10000 do
  a = obj1:boo("Hello")
end
print("Duração: "..socket.gettime() - start_time)
assert(a, 2)

print("")

print("Execução de boo 10000x com uma string grande")
local big_string = ""
for i = 1, 1000 do big_string = big_string..'a' end
start_time = socket.gettime()
for i = 1,10000 do
  a = obj1:boo(big_string)
end
print("Duração: "..socket.gettime() - start_time)
assert(a, 2)

print("")

function serialize_table(t)
	local s = '{'
	for i,v in ipairs(t) do
    if     (type(v) == "string") then s = s.."[["..v.."]]"
		elseif (type(v) == "number") then s = s..v
		end

		if i ~= #t then s = s..',' end
	end
	return s..'}'
end

local double_table = {}
for i = 1,100 do
  double_table[i] = 2.0
end

local serialized_table
print("Serialização de table de 100 doubles")
start_time = socket.gettime()
serialized_table = serialize_table(double_table)
print("Duração: "..socket.gettime() - start_time)

print("")

print("Execução de boo com tabela de 100 doubles, 10000x")
start_time = socket.gettime()
for i = 1,10000 do
  a = obj1:boo(serialized_table)
end
print("Duração: "..socket.gettime() - start_time)

print("")
