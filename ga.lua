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

local function crossoverChromosomeText(chromosome, point)
    local copy = {}
    for i, bit in ipairs(chromosome) do
        table.insert(copy, bit)
        if i == point then
            table.insert(copy, '|')
        end
    end

    return table.concat(copy)
end

local function fitnessChromosomeText(chromosome, fitness)
    return ("%s [%d]"):format(table.concat(chromosome), fitness)
end

local function mutationChromosomeText(chromosome)
    local mutation = chromosome.mutation
    if mutation then
        local colored = {}
        local normalColor = {1, 1, 1}
        local mutationColor = {1, 0, 0}
        for i, bit in ipairs(chromosome) do
            local color = mutation[i] and mutationColor or normalColor
            table.insert(colored, color)
            table.insert(colored, tostring(bit))
        end
        return colored
    else
        return table.concat(chromosome)
    end
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
            local chromosomeLength = 9
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
                    child1.crossover = point
                end

                for i = 1, chromosomeLength do
                    table.insert(child1, parent1[i])
                    table.insert(child2, parent2[i])

                    if i == point then
                        parent1, parent2 = parent2, parent1
                    end
                end

                -- mutation
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
                    child.mutation = mutation
                end

                return child1, child2
            end

            for i = 1, 100 do
                -- selection
                local fitnessMap = {}
                for _, chromosome in ipairs(population) do
                    fitnessMap[chromosome] = getFitness(chromosome)
                end

                table.sort(population, function(a, b)
                    return fitnessMap[a] > fitnessMap[b]
                end)

                local matingPool = M.head(population, matingPoolSize)
                local elite = matingPool[1]

                local offspring = {}
                for parent1, parent2 in eachCouple(matingPool) do
                    M.push(offspring, mate(parent1, parent2))
                end
                table.insert(offspring, elite)

                coroutine.yield {
                    population = population,
                    matingPool = matingPool,
                    offspring = offspring,
                    fitnessMap = fitnessMap
                }

                population = offspring
            end
        end,

        drawState = function(state_index, state)
            local population = state.population
            local matingPool = state.matingPool
            local offspring = state.offspring
            local fitnessMap = state.fitnessMap

            love.graphics.printf(("%d%%"):format(state_index), 10, 10, 100)

            local selectedColor = {0, 1, 0}
            local normalColor = {1, 1, 1}

            for i, chromosome in ipairs(population) do
                love.graphics.setColor(i <= 5 and selectedColor or normalColor)
                love.graphics.printf(fitnessChromosomeText(chromosome,
                                                           fitnessMap[chromosome]),
                                     10, 10 + i * 20, 100)
            end

            local groupWidth = 200
            love.graphics.rectangle('line', 200, 10, groupWidth, 25)
            local elite = offspring[#offspring]
            local eliteText = fitnessChromosomeText(elite, fitnessMap[elite])
            love.graphics.printf({selectedColor, eliteText}, 205, 15, 200)

            local coupleIndex = 1
            for parent1, parent2 in eachCouple(matingPool) do
                local child1 = offspring[1 + (coupleIndex - 1) * 2]
                local child2 = offspring[2 + (coupleIndex - 1) * 2]
                local crossover = child1.crossover

                local x = 200
                local y = 40 + (coupleIndex - 1) * 55

                love.graphics.rectangle('line', x, y, groupWidth, 50)
                love.graphics.printf(
                    crossoverChromosomeText(parent1, crossover), x + 5, y + 5,
                    100)
                love.graphics.printf(
                    crossoverChromosomeText(parent2, crossover), x + 5, y + 30,
                    100)

                love.graphics.printf(mutationChromosomeText(child1), x + 105,
                                     y + 5, 100)
                love.graphics.printf(mutationChromosomeText(child2), x + 105,
                                     y + 30, 100)

                coupleIndex = coupleIndex + 1
            end
        end
    }

    self:addSprite(algo)

    algo:start()
end

function GA:switched()
    love.window.setTitle 'Genetic Algorithm'
end

return GA
