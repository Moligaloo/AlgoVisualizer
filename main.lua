local json = require 'dkjson'
local class = require 'middleclass'
local _ = require 'underscore'
local channel = love.thread.newChannel()
local g = love.graphics

local Context = class('Context')

function Context:initialize()
	self.symbol_names = {}
	self.symbol_table = {}
end

function Context:getSymbolByName(name)
	return self.symbol_table[name]
end

function Context:setSlot(slotName, slotValue, slotType)
	if self.symbol_names[slotName] then
		error(("already exists symbol named %s"):format(slotName))
	end

	table.insert(self.symbol_names, slotName)
	self.symbol_table[slotName] = {
		type = slotType,
		value = slotValue
	}
end

function Context:updateSlot(slotName, slotValue)
	if self.symbol_names[slotName] == nil then
		error(("no symbol named %s"):format(slotName))
	end

	self.symbol_table[slotName].value = slotValue
end

local System = class('System')

function System:initialize()
	self.call_stack = {}
end

function System:context()
	return self.call_stack[#self.call_stack]
end

function System:start()
	table.insert(self.call_stack, Context:new())
end

local system = System:new()

local function getObjectByName(name)
	if name then
		if name == '$SYSTEM' then
			return system
		else
			return system:context():getSymbolByName(name)
		end
	else
		return system:context()
	end
end

function love.load()
	local thread = love.thread.newThread('server.lua')
	thread:start(channel)
end

function love.update(dt)
	local cmd = channel:pop()
	if cmd then
		print(json.encode(cmd))

		local object = getObjectByName(cmd.name)
		local func = object[cmd.method]
		local args = { object }
		if cmd.args then
			for _, arg in ipairs(cmd.args) do
				table.insert(args, arg)
			end
		end

		if func then
			func(unpack(args))
		else
			error(("method %s is missing for object"):format(cmd.method))
		end
	end
end

function love.draw()
	g.rectangle('line', 0, 0, 100, 100)
end
