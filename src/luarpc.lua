local socket = require "socket"

local M     = {}
M.servers   = {}
M.sockets   = {}
M.conns     = {}
M.rpcmap    = {}

M.idltype2lua = {
	["string"] = "string",
	["double"] = "number",
	["void"  ] = nil,      -- Looks fishy...
}

-- open ports in the LAB: [5500 - 5509]
M.get_next_port = (function(first)
	local port = first or 5500
	return function()
		port = port+1
		return port-1
	end
end)()

function M.createServant(impl, iface, port)
	port = port or M.get_next_port()
	sock, err = socket.bind("*", port)
	print("serving on: "..port)

	-- TODO: check if impl and iface match
	table.insert(M.sockets, sock)
	M.servers[sock] = impl
end

function list(t)
	for k,v in pairs(t) do
		print(k,v)
	end
end

-- in : table with parameters
-- out: string in the form '{parameter1, parameter2, ...}'
function M.marshall_table(t)
	local s = '{'
	for i,v in ipairs(t) do
		if     (type(v) == "string") then s = s.."'"..v.."'"
		elseif (type(v) == "number") then s = s..v
		end

		if i ~= #t then s = s..',' end
	end
	return s..'}'
end

-- in : string with encoded parameter list
-- out: table as array with parameters in order
function M.unmarshall(s)
	return loadstring(s)
end

-- name: function name
-- args: table with parameters
-- ret : string in the form 'return{`name`={args}}
function M.marshall_call(name, args)
	return 'return{'..name..'='..M.marshall_table(args)..'}'
end

-- in : string with encoded call
-- out: function name, table with parameters
function M.unmarshall_call(s)
	for call,params in pairs(M.unmarshall(s)()) do
		return call, params
	end
end

function M.marshall_ret(t)
	return 'return'..M.marshall_table(t)
end

function M.unmarshall_ret(t)
	return M.unmarshall(t)()
end

function M.waitIncoming()
	while true do
		local rxs, txs, ers = socket.select(M.sockets)
		for _,conn in ipairs(rxs) do
			local client = conn
			if M.servers[conn] then
				client = assert(conn:accept())
				client:settimeout(0.01) -- no timeout
				M.servers[client] = M.servers[conn]
			end

			repeat
				local m,e = client:receive()
				if m == nil or e == "timeout" then break end

				if M.servers[client] and m then
					local call, args = M.unmarshall_call(m)
					-- TODO: validate that args conform with the IDL
					local ret = {M.servers[client][call](unpack(args))}
					client:send(M.marshall_ret(ret)..'\n')
				else client:send("__ERRORPC\n")
				end
			until e

			if m == "closed" then
				table.remove(M.sockets, k)
				M.servers[client] = nil
			end
		end
	end
end

function M.createProxy(ip, port, iface)
	local proxy = {}

	for k,v in pairs(iface.methods) do
		proxy[k] = function(self, ...)

			-- build message and validate parameters
			local params = {...}

			--print(#params, #iface.methods[k].args)
			-- check
			assert(#params == #iface.methods[k].args)
			for pk,pv in ipairs(params) do
				local idltype = iface.methods[k].args[pk].type
				assert(type(params[pk]) == M.idltype2lua[idltype])
			end
			--marshall
			local msg = M.marshall_call(k, params)..'\n'

			-- send
			self.conn:send(msg)

			-- receive
			local s,m = self.conn:receive()
			local ret = M.unmarshall_ret(s)
			-- TODO: validate that ret values conform with IDL
			return unpack(ret)
		end
	end

	proxy.conn = socket.connect(ip, port)
	return proxy
end

return M
