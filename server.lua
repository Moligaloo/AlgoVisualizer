local args = { ... }
local channel = args[1]
local socket = require('socket')
local json = require('dkjson')

local master_socket = socket.bind('*', 5555)

while true do
	local slave_socket = master_socket:accept()
	while true do
		local line = slave_socket:receive('*l')
		if line == nil then
			break
		end

		local object = json.decode(line)
		if type(object) == 'table' then
			channel:push(object)
			if object.name == 'quit' then
				break
			end
		end
	end
end


