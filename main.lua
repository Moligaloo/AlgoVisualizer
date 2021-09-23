local M = require 'moses'
local defaultFont
local scenes = M.map({'sa', 'aco', 'ga'}, function(name)
    return require(name)()
end)
local scene = scenes[3]

function love.load()
    defaultFont = love.graphics.newFont 'kai.ttf'
    scene:switched()
end

function love.mousepressed(x, y)
    scene:mousepressed(x, y)
end

function love.mousemoved(x, y)
    scene:mousemoved(x, y)
end

function love.mousereleased()
    scene:mousereleased()
end

function love.update(dt)
    scene:update(dt)
end

function love.keypressed(key)
    local index = tonumber(key)
    if index then
        local newScene = scenes[index]
        if newScene then
            scene = newScene
            scene:switched()
        end
    elseif key == 'escape' then
        love.event.quit(0)
    end
end

function love.keyreleased(key)
    scene:keyreleased(key)
end

function love.draw()
    love.graphics.setFont(defaultFont)
    love.graphics.clear()

    scene:draw()
end

