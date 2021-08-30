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
    coord = Coordination {
        x = 20,
        y = love.graphics.getHeight() / 2 - 20,
        width = love.graphics.getWidth() - 40,
        height = love.graphics.getHeight() / 2 - 40
    }
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
                local transfered = delta < 0 or love.math.random() < probability

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

            local currentX = coord:mapToGraph(point)
            love.graphics.setColor(1, 0, 0)
            love.graphics.line(currentX, coord.y - 200, currentX, coord.y)
            local newX = coord:mapToGraph(newPoint)
            love.graphics.setColor(0, 1, 0)
            love.graphics.line(newX, coord.y - 200, newX, coord.y)

            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(([[
step: %d
temperature: %.2fK
point: %d -> %d 
probability: %.2f%%
energy: %.2f -> %.2f (%.2f)
            ]]):format(state_index, temperature, point, newPoint,
                       probability * 100, energy, newEnergy, delta),
                                 love.graphics.getWidth() - 250, 10, 250, 'left')
        end
    }

    sprites = {coord, label, simulated_annealing}
end

function love.resize(newWidth, newHeight)
    coord.x = 20
    coord.y = newHeight / 2 - 20
    coord.width = newWidth - 40
    coord.height = newHeight / 2 - 40
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

    local states = simulated_annealing.states
    if states and #states >= 2 then
        local temperature_points = {}
        local origin_x = 20
        local origin_y = love.graphics.getHeight() - 20
        local width = love.graphics.getWidth() - 40
        local height = love.graphics.getHeight() / 2 - 40

        for i, state in ipairs(states) do
            local temperature = state[5]
            local ratio = temperature / 1000
            local x = origin_x + i * 10
            local y = origin_y - height * ratio

            table.insert(temperature_points, x)
            table.insert(temperature_points, y)
        end

        love.graphics.setColor(1, 0, 0)
        love.graphics.line(temperature_points)
    end

end

