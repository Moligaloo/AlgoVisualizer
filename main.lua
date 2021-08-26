local Slider = require 'slider'
local Button = require 'button'
local Coordination = require 'coordination'
local Label = require 'label'
local SA = require 'sa'

local coord = Coordination()
local label = Label {x = 100, y = 100}
local sa = SA()

local sprites = {
    coord,
    Button {
        text = 'Start',
        x = 10,
        y = 10,
        width = 80,
        height = 30,
        onClick = function()
            sa:start()
        end
    },
    Slider {x = 10, y = 60, width = 100},
    label,
    sa
}

function love.load()
    love.window.setTitle('Simulated Annealing')
end

function love.mousepressed(x, y, button, istouch, presses)
    for i = #sprites, 1, -1 do
        local sprite = sprites[i]
        if sprite:mousepressed(x, y) then
            break
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    for _, sprite in ipairs(sprites) do
        sprite:mousemoved(x, y)
    end

    local logic_x = coord:mapToLogic(x)
    local logic_y = coord:getValue(logic_x)
    if logic_y then
        label.text = string.format("(%.2f, %.2f)", logic_x, logic_y)
    end
end

function love.mousereleased()
    for _, sprite in ipairs(sprites) do
        sprite:mousereleased()
    end
end

function love.update(dt)
    for _, sprite in ipairs(sprites) do
        sprite:update(dt)
    end
end

function love.draw()
    for _, sprite in ipairs(sprites) do
        sprite:draw()
    end
end

