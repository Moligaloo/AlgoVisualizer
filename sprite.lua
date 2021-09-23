local class = require 'middleclass'

local Sprite = class('Sprite')
local M = require 'moses'

function Sprite:initialize(config)
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0

    if config then
        M.extend(self, config)
    end
end

function Sprite:mousepressed(x, y)
    return self:isHit(x, y)
end

function Sprite:mousemoved(x, y)
end

function Sprite:mousereleased(x, y)
end

function Sprite:draw()
end

function Sprite:isHit(x, y)
    return (x >= self.x and x <= self.x + self.width) and
               (y >= self.y and y <= self.y + self.height)
end

function Sprite:update(dt)
end

function Sprite:keyreleased(key)
end

return Sprite
