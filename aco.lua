-- ant colony optimization
local Scene = require 'scene'
local Sprite = require 'sprite'

local ACO = Scene:subclass 'ACO'
local Node = Sprite:subclass 'Node'
local ByteOfA = string.byte 'A'

function Node:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', self.x, self.y, 15, 100)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.label, self.x - 9, self.y - 8, 20, 'center')
end

function ACO:initialize(config)
    Scene.initialize(self, config)
    self.nodes = {}
end

function ACO:mousepressed(x, y)
    local newNode = Node {
        x = x,
        y = y,
        label = string.char(ByteOfA + #self.nodes)
    }
    table.insert(self.nodes, self:addSprite(newNode))
end

function ACO:switched()
    love.window.setTitle 'Ant Colony Optimization'
end

return ACO

