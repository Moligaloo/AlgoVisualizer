local Sprite = require 'sprite'

local Button = Sprite:subclass('Button')

function Button:initialize(config)
    Sprite.initialize(self, config)

    self.width = 80
    self.height = 30
end

function Button:draw()
    local blueColor = {0, 53 / 255, 106 / 255}
    local whiteColor = {1, 1, 1}
    local blackColor = {0, 0, 0}

    love.graphics.setColor(self.hovered and blueColor or blackColor)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 4,
                            4)

    love.graphics.setColor(whiteColor)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height, 4,
                            4)
    love.graphics.printf(self.text, self.x, self.y + 7, self.width, 'center')
end

function Button:mousemoved(x, y)
    self.hovered = self:isHit(x, y)
end

function Button:mousereleased()
    if self.hovered and self.onClick then
        self.onClick()
    end
end

function Button:mousepressed()
    return self.hovered
end

return Button
