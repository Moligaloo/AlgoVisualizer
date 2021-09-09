-- ant colony optimization
local Scene = require 'scene'
local Sprite = require 'sprite'
local _ = require 'underscore'

local ACO = Scene:subclass 'ACO'
local Node = Sprite:subclass 'Node'
local ByteOfA = string.byte 'A'
local FarEnoughRadius = 60

function Node:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', self.x, self.y, 15, 100)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.label, self.x - 9, self.y - 8, 20, 'center')
end

function ACO:initialize(config)
    Scene.initialize(self, config)
    self:generate(10)
end

function ACO:addNode(x, y)
    local newNode = Node {
        x = x,
        y = y,
        label = string.char(ByteOfA + #self.nodes)
    }
    table.insert(self.nodes, self:addSprite(newNode))
end

function ACO:mousepressed(x, y)
    if self:farEnough(x, y) then
        self:addNode(x, y)
    end
end

function ACO:farEnough(x, y)
    local squaredDistance = FarEnoughRadius * FarEnoughRadius
    return _.all(self.nodes, function(node)
        local dx = x - node.x
        local dy = y - node.y
        local squaredSum = dx * dx + dy * dy
        return squaredSum >= squaredDistance
    end)
end

function ACO:generate(n)
    self.sprites = {}
    self.nodes = {}
    local margin = 50
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    for i = 1, n do
        local x, y
        repeat
            x = love.math.random(margin, width - margin)
            y = love.math.random(margin, height - margin)
        until self:farEnough(x, y)

        self:addNode(x, y)
    end
end

function ACO:keyreleased(key)
    if key == 'return' then
        -- start algorithm
    elseif key == 'c' then
        self.sprites = {}
        self.nodes = {}
    elseif key == 'g' then
        self:generate(10)
    end
end

function ACO:switched()
    love.window.setTitle 'Ant Colony Optimization'
end

return ACO

