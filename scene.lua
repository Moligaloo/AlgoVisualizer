local Sprite = require 'sprite'

local Scene = Sprite:subclass 'Scene'

function Scene:initialize(config)
    Sprite.initialize(self, config)
    self.sprites = self.sprites or {}
end

function Scene:addSprite(sprite)
    table.insert(self.sprites, sprite)
    return sprite
end

function Scene:mousepressed(x, y)
    local sprites = self.sprites
    for i = #sprites, 1, -1 do
        local sprite = sprites[i]
        if sprite:mousepressed(x, y) then
            break
        end
    end
end

function Scene:mousemoved(x, y)
    local sprites = self.sprites
    for _, sprite in ipairs(sprites) do
        sprite:mousemoved(x, y)
    end
end

function Scene:mousereleased()
    local sprites = self.sprites
    for _, sprite in ipairs(sprites) do
        sprite:mousereleased()
    end
end

function Scene:update(dt)
    local sprites = self.sprites
    for _, sprite in ipairs(sprites) do
        sprite:update(dt)
    end
end

function Scene:draw()
    local sprites = self.sprites

    for _, sprite in ipairs(sprites) do
        sprite:draw()
    end
end

function Scene:switched()
end

return Scene
