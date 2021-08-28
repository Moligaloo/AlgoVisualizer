local Slider = require 'slider'
local Button = require 'button'
local Coordination = require 'coordination'
local Label = require 'label'
local Algorithm = require 'algorithm'

local yield = coroutine.yield
local coord, sprites, label, point, temperature, simulated_annealing

local function getEnergy(point)
    return coord:getValue(point)
end

local function randomShift(point)
    while true do
        local nextPoint = point + love.math.random(-200, 200)
        if coord:getValue(nextPoint) then
            return nextPoint
        end
    end
end

local function cooldown(temperature)
    return temperature * 0.9
end

function love.load()
    love.window.setTitle('Simulated Annealing')
    coord = Coordination()
    label = Label {x = 100, y = 100}

    simulated_annealing = Algorithm {
        step = function()
            point = coord:getRandomPoint()
            yield()

            temperature = 1000
            while temperature > 1 do
                temperature = cooldown(temperature)

                local energy = getEnergy(point)
                local nextPoint = randomShift(point)
                local delta = getEnergy(nextPoint) - energy
                if delta < 0 or
                    (love.math.random() < math.exp(-delta / temperature)) then
                    point = nextPoint
                end

                yield()
            end
        end
    }

    sprites = {coord, label, simulated_annealing}
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

function love.keyreleased(key)
    if key == 'space' or key == 'return' then
        simulated_annealing:start()
    end
end

function love.draw()
    for _, sprite in ipairs(sprites) do
        sprite:draw()
    end

    if point then
        local x = coord:mapToGraph(point)
        local middleY = love.graphics.getHeight() / 2
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(x, middleY - 200, x, middleY + 200)
    end

    if temperature then
        love.graphics.setColor(1, 0, 0)
        love.graphics
            .print(("Temperature: %.2f K"):format(temperature), 200, 10)
    end
end

