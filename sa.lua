-- simulated annealing algorithm
local Scene = require 'scene'
local Coordination = require 'coordination'
local Algorithm = require 'algorithm'
local M = require 'moses'

local SA = Scene:subclass 'SA'

function SA:initialize(config)
    Scene.initialize(self, config)

    local yield = coroutine.yield
    local coord = Coordination {
        x = 20,
        y = love.graphics.getHeight() / 2 - 20,
        width = love.graphics.getWidth() - 40,
        height = love.graphics.getHeight() / 2 - 40
    }

    local algo = Algorithm {
        step = function()
            local function getEnergy(point)
                return coord:getValue(point)
            end

            local function cooldown(temperature)
                return temperature * 0.9
            end

            local point = coord:getRandomPoint()
            local temperature = 1000
            while temperature > 1 do
                local energy = getEnergy(point)
                local newPoint = coord:randomShift(point, 200)
                local newEnergy = getEnergy(newPoint)
                local delta = newEnergy - energy
                local probability = math.exp(-delta / temperature)
                local transited = delta < 0 or love.math.random() < probability

                yield {
                    point,
                    newPoint,
                    energy,
                    newEnergy,
                    temperature,
                    probability,
                    transited
                }

                temperature = cooldown(temperature)
                if transited then
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

            local currentX = coord:mapToGraph(point)
            love.graphics.setColor(1, 0, 0)
            love.graphics.line(currentX, coord.y - 200, currentX, coord.y)
            local newX = coord:mapToGraph(newPoint)
            love.graphics.setColor(0, 1, 0)
            love.graphics.line(newX, coord.y - 200, newX, coord.y)

            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(([[
步骤: %d
温度: %.2f K
点: %d -> %d 
转移概率: %.2f%%
能量: %.2f -> %.2f (%.2f)
            ]]):format(state_index, temperature, point, newPoint,
                       probability * 100, energy, newEnergy, delta),
                                 love.graphics.getWidth() - 250, 10, 250, 'left')
        end,

        drawStates = function(states)
            if states and #states >= 2 then
                local temperaturePoints = {}
                local energyPoints = {}
                local newEnergyPoints = {}
                local origin_x = 20
                local origin_y = love.graphics.getHeight() - 20
                local width = love.graphics.getWidth() - 40
                local height = love.graphics.getHeight() / 2 - 40

                for i, state in ipairs(states) do
                    local temperature = state[5]
                    local ratio = temperature / 1000
                    local x = origin_x + i * 10
                    local y = origin_y - height * ratio

                    M.push(temperaturePoints, x, y)

                    local energy = state[3]
                    M.push(energyPoints, x, origin_y - energy)

                    local newEnergy = state[4]
                    M.push(newEnergyPoints, x, origin_y - newEnergy)
                end

                love.graphics.setColor(1, 1, 1)
                love.graphics.line(temperaturePoints)

                love.graphics.setColor(1, 0, 0)
                love.graphics.line(energyPoints)

                love.graphics.setColor(0, 1, 0)
                love.graphics.line(newEnergyPoints)
            end
        end
    }

    self.coord = coord
    self.algo = algo

    self:addSprites{coord, algo}
end

function SA:keyreleased(key)
    if key == 'space' or key == 'return' then
        if self.coord:isReady() then
            self.algo:start()
            self.coord.enabled = false
        end
    elseif key == 'left' then
        self.algo:left()
    elseif key == 'right' then
        self.algo:right()
    elseif key == 'r' then
        self.algo:reset()
        self.coord.enabled = true
    end
end

function SA:switched()
    love.window.setTitle 'Simulated Annealing'
end

return SA
