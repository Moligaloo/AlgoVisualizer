local defaultFont
local sa = require 'sa'
local aco = require 'aco'
local scene = aco

function love.load()
    love.window.setTitle(scene.title)
    defaultFont = love.graphics.newFont 'kai.ttf'
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

function love.keyreleased(key)
    scene:keyreleased(key)
end

function love.draw()
    love.graphics.setFont(defaultFont)
    love.graphics.clear()

    scene:draw()
end

