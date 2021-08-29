local Slider = require 'slider'
local Button = require 'button'
local Coordination = require 'coordination'
local Label = require 'label'
local Algorithm = require 'algorithm'

local yield = coroutine.yield
local coord, sprites, label, simulated_annealing

local function getEnergy(point)
    return coord:getValue(point)
end

local function randomShift(point)
    while true do
        local newPoint = point + love.math.random(-200, 200)
        if coord:getValue(newPoint) then
            return newPoint
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
            local point = coord:getRandomPoint()
            local temperature = 1000
            while temperature > 1 do
                local energy = getEnergy(point)
                local newPoint = randomShift(point)
                local newEnergy = getEnergy(newPoint)
                local delta = newEnergy - energy
                local probability = math.exp(-delta / temperature)
                local transfered = false
                if love.math.random() < probability then
                    transfered = true
                end

                yield {
                    point,
                    newPoint,
                    energy,
                    newEnergy,
                    temperature,
                    probability,
                    transfered
                }

                temperature = cooldown(temperature)
                if transfered then
                    point = newPoint
                end
            end
        end,

        drawState = function(state_index, state)
            local point = state[1]
            local newPoint = state[2]
            local energy = state[3]
            local newEnergy = state[4]
            local delta = newEnergy - energy
            local temperature = state[5]
            local probability = state[6]
            local transfered = state[7]

            local x = coord:mapToGraph(point)
            local middleY = love.graphics.getHeight() / 2
            love.graphics.setColor(1, 0, 0)
            love.graphics.line(x, middleY - 200, x, middleY + 200)

            love.graphics.printf(([[
step: %d
temperature: %.2fK
point: %d -> %d 
probability: %.2f%%
energy: %.2f -> %.2f (%.2f)
            ]]):format(state_index, temperature, point, newPoint,
                       probability * 100, energy, newEnergy, delta), 10, 10,
                                 300, 'left')
        end,

        onComplete = function()
            local sliderWidth = 400
            local slider = Slider {
                x = (love.graphics.getWidth() - sliderWidth) / 2,
                y = love.graphics.getHeight() - 30,
                width = 400,
                value = 1,
                onValueChanged = function(progress)
                    simulated_annealing:setProgress(progress)
                end
            }

            simulated_annealing.onProgressChanged = function(progress)
                slider.value = progress
            end

            coord.enabled = false
            table.insert(sprites, slider)
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
    elseif key == 'left' then
        simulated_annealing:left()
    elseif key == 'right' then
        simulated_annealing:right()
    end
end

function love.draw()
    for _, sprite in ipairs(sprites) do
        sprite:draw()
    end

end

