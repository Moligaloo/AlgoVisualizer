local Scene = require 'scene'
local Algorithm = require 'algorithm'
local GA = Scene:subclass 'GA'
local M = require 'moses'

local function randomBit()
    return love.math.random(0, 1)
end

local function randomBits(length)
    return M.map(M.range(length), randomBit)
end

local function eachCouple(pool)
    return coroutine.wrap(function()
        for i = 1, #pool - 1 do
            for j = i + 1, #pool do
                coroutine.yield(pool[i], pool[j])
            end
        end
    end)
end

function GA:initialize(config)
    Scene.initialize(self, config)

    local weights = {2, 1, 6, 1, 4, 9, 5, 8, 3}
    local prices = {5, 3, 15, 5, 6, 18, 8, 20, 8}
    local maxWeight = 25

    local function getFitness(chromosome)
        local totalWeight, totalPrice = 0, 0
        for i, bit in ipairs(chromosome) do
            if bit == 1 then
                totalWeight = totalWeight + weights[i]
                totalPrice = totalPrice + prices[i]
            end
        end

        return totalWeight <= maxWeight and totalPrice or 0
    end

    local algo = Algorithm {
        tick_duration = 0.02,
        step = function()
            local populationSize = 21
            local matingPoolSize = 5
            local chromosomeLength = #weights
            local crossoverRate = 0.8
            local mutationRate = 0.1

            local population = M.map(M.range(populationSize), function()
                return randomBits(chromosomeLength)
            end)

            local function mate(parent1, parent2)
                local point
                local child1, child2 = {}, {}

                -- crossover
                if love.math.random() < crossoverRate then
                    point = love.math.random(chromosomeLength)
                end

                for i = 1, chromosomeLength do
                    table.insert(child1, parent1[i])
                    table.insert(child2, parent2[i])

                    if i == point then
                        parent1, parent2 = parent2, parent1
                    end
                end

                -- mutation
                local result = {}
                for _, child in ipairs {child1, child2} do
                    local mutation = nil
                    for i = 1, chromosomeLength do
                        if love.math.random() < mutationRate then
                            if mutation == nil then
                                mutation = {}
                            end
                            child[i] = child[i] == 0 and 1 or 0
                            mutation[i] = true
                        end
                    end

                    result[child] = {crossover = point, mutation = mutation}
                end

                return result
            end

            for i = 1, 100 do
                -- selection
                local fitnessMap = {}
                for _, chromosome in ipairs(population) do
                    fitnessMap[chromosome] = getFitness(chromosome)
                end

                M.sort(population, function(a, b)
                    return fitnessMap[a] > fitnessMap[b]
                end)

                local matingPool = M.head(population, matingPoolSize)
                local elite = matingPool[1]

                local matingResult = {}
                for parent1, parent2 in eachCouple(matingPool) do
                    M.extend(matingResult, mate(parent1, parent2))
                end

                local offspring = M.append({elite}, M.keys(matingResult))

                coroutine.yield {
                    population = population,
                    matingPool = matingPool,
                    offspring = offspring,
                    fitnessMap = fitnessMap,
                    matingResult = matingResult
                }

                population = offspring
            end
        end,

        drawState = function(state_index, state)
            local population = state.population
            local matingPool = state.matingPool
            local offspring = state.offspring
            local fitnessMap = state.fitnessMap
            local matingResult = state.matingResult

            love.graphics.printf(("%d%%"):format(state_index), 10, 10, 100)

            local selectedColor = {0, 1, 0}
            local normalColor = {1, 1, 1}

            local function chromosomeText(chromosome)
                local fitness = fitnessMap[chromosome]
                return ("%s [%d]"):format(table.concat(chromosome), fitness)
            end

            for i, chromosome in ipairs(population) do
                love.graphics.setColor(i <= 5 and selectedColor or normalColor)
                love.graphics.printf(chromosomeText(chromosome), 10,
                                     10 + i * 20, 100)
            end

            local groupWidth = 200
            love.graphics.rectangle('line', 200, 10, groupWidth, 25)
            local elite = offspring[1]
            local eliteText = chromosomeText(elite)
            love.graphics.printf({selectedColor, eliteText}, 205, 15, 200)

            local parent1Color = {1, 1, 0}
            local parent2Color = {0, 0, 1}

            local coupleIndex = 1
            for parent1, parent2 in eachCouple(matingPool) do
                local child1 = offspring[2 + (coupleIndex - 1) * 2]
                local child2 = offspring[3 + (coupleIndex - 1) * 2]
                local crossover = matingResult[child1].crossover

                local function parentText(parent)
                    if crossover then
                        local copy = M.clone(parent)
                        table.insert(copy, crossover + 1, '|')
                        return table.concat(copy)
                    else
                        return table.concat(parent)
                    end
                end

                local function childText(child, parentNo)
                    local mutation = matingResult[child].mutation
                    local colored = {}
                    local leftColor, rightColor = parent1Color, parent2Color
                    if parentNo == 2 then
                        leftColor, rightColor = parent2Color, parent1Color
                    end
                    local normalColor = leftColor
                    local mutationColor = {1, 0, 0}
                    for i, bit in ipairs(child) do
                        local mutated = (mutation and mutation[i])
                        local color = mutated and mutationColor or normalColor
                        M.push(colored, color, bit)

                        if i == crossover then
                            normalColor = rightColor
                        end
                    end
                    return colored
                end

                local x = 200
                local y = 40 + (coupleIndex - 1) * 55

                love.graphics.rectangle('line', x, y, groupWidth, 50)
                love.graphics.setColor(parent1Color)
                love.graphics.printf(parentText(parent1), x + 5, y + 5, 100)
                love.graphics.setColor(parent2Color)
                love.graphics.printf(parentText(parent2), x + 5, y + 30, 100)
                love.graphics.setColor(normalColor)

                love.graphics.printf(childText(child1, 1), x + 105, y + 5, 100)
                love.graphics.printf(childText(child2, 2), x + 105, y + 30, 100)

                coupleIndex = coupleIndex + 1
            end

            local cellX, cellY = 500, 10
            for i = 1, #weights do
                local weight = weights[i]
                local price = prices[i]
                local cellWidth = price * 10
                local cellHeight = weight * 15

                local mode = elite[i] == 1 and 'fill' or 'line'
                love.graphics.setColor(0, 0, 1)
                love.graphics.rectangle(mode, cellX, cellY, cellWidth,
                                        cellHeight)
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle('line', cellX, cellY, cellWidth,
                                        cellHeight)

                love.graphics.printf(weight, cellX + cellWidth + 5,
                                     cellY + cellHeight / 2 - 6, 100)
                love.graphics.printf(price, cellX, cellY + cellHeight / 2 - 6,
                                     cellWidth, 'center')

                cellY = cellY + cellHeight
            end
        end
    }

    self:addSprite(algo)

    algo:start()
    algo:runStep()
    algo:pause()

    self.algo = algo
end

function GA:keyreleased(key)
    if key == 'c' then
        self.algo:continue()
    elseif key == 'n' then
        if not self.algo:isDone() then
            self.algo:runStep()
        end
    elseif key == 'p' then
        self.algo:pause()
    elseif key == 'r' then
        self.algo:reset()
        self.algo:start()
    end
end

function GA:switched()
    love.window.setTitle 'Genetic Algorithm'
end

return GA
