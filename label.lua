local Sprite = require 'sprite'

local Label = Sprite:subclass 'Label'

function Label:draw()
    local text = self.text
    if type(text) == 'function' then
        text = text()
    end

    if text then
        love.graphics.print(text, self.x, self.y)
    end
end

return Label
