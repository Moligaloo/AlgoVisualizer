local Sprite = require 'sprite'

local Slider = Sprite:subclass 'Slider'

local rect_width = 10
local rect_height = 10

function Slider:initialize(config)
    Sprite.initialize(self, config)

    self.value = self.value or 0
end

function Slider:draw()
    local x = self.x
    local y = self.y
    local width = self.width
    local value = self.value

    love.graphics.setColor(1, 1, 1)

    love.graphics.line(x, y, x + width, y)

    if self.dragging then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.rectangle('fill', x + width * value - rect_width / 2,
                            y - rect_height / 2, rect_width, rect_height)
end

function Slider:mousepressed(x, y)
    local center_x = self.x + self.value * self.width
    local center_y = self.y
    local dx = x - center_x
    local dy = y - center_y

    if math.abs(dx) < rect_width / 2 and math.abs(dy) < rect_height / 2 then
        self.dragging = dx
    else
        self.dragging = nil
    end

    return self.dragging ~= nil
end

function Slider:mousereleased()
    self.dragging = nil
end

function Slider:mousemoved(x, y)
    if self.dragging then
        local center_x = x + self.dragging
        local value = (center_x - self.x) / self.width
        if value >= 0 and value <= 1 then
            self.value = value

            if self.onValueChanged then
                self.onValueChanged(value)
            end
        end
    end
end

return Slider
