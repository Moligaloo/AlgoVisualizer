-- genetic algorithm

Scene = require 'scene'
Algorithm = require 'algorithm'
M = require 'moses'

import yield from coroutine
import random from love.math

randomBit = -> random 0,1
randomBits = (length) -> [randomBit! for i=1, length]

eachCouple = (pool) ->
    coroutine.wrap ->
        for i=1, #pool-1
            for j=i+1, #pool
                yield pool[i], pool[j]

dotProduct = (vector1, vector2) ->
    M.sum M.zipWith M.op.mul, vector1, vector2

xor = (a,b) ->
    a==b and 0 or 1

class GA extends Scene
    new: (config) =>
        super config

        weights = {2, 1, 6, 1, 4, 9, 5, 8, 3}
        prices = {5, 3, 15, 5, 6, 18, 8, 20, 8}
        maxWeight = 25

        getFitness = (chromosome) ->
            totalWeight = dotProduct chromosome, weights 
            if totalWeight <= maxWeight then dotProduct chromosome, prices else 0
        
        algo = Algorithm 
            tick_duration: 0.02
            step: ->
                populationSize = 21
                matingPoolSize = 5
                chromosomeLength = #weights
                crossoverRate = 0.8
                mutationRate = 0.1

                recombine = (another, crossover) =>
                    if crossover
                        M.append M.head(@, crossover), M.last(another, #another-crossover)
                    else
                        @
                
                mutate = (mutation) =>
                    M.zipWith xor, @, mutation

                population = [randomBits(chromosomeLength) for i=1, populationSize]
                mate = (parent1, parent2) ->
                    crossover = if random! < crossoverRate then random(chromosomeLength-1) else nil
                    reproduce = (p1, p2) ->
                        mutation = [(random! < mutationRate and 1 or 0) for i=1,chromosomeLength]
                        child = p1 
                            |> recombine p2, crossover
                            |> mutate mutation

                        {:child, :crossover, :mutation}

                    { reproduce(parent1, parent2), reproduce(parent2, parent1) }
                                    
                for i=1, 100 
                    fitnessMap = {chromosome, getFitness(chromosome) for chromosome in *population}
                    table.sort population, (a,b)-> fitnessMap[a]>fitnessMap[b]

                    matingPool = M.head population, matingPoolSize
                    elite = matingPool[1]

                    matingResult = [mate parent1, parent2 for parent1, parent2 in eachCouple matingPool] |> M.flatten true

                    offspring = M.append {elite}, M.map(matingResult, => @child)
                
                    yield {
                        population
                        matingPool
                        offspring
                        fitnessMap
                        matingResult
                    }

                    population = offspring

            drawState: (state_index, state) ->
                {population, matingPool, offspring, fitnessMap, matingResult} = state

                selectedColor = {0,1,0}
                dropColor = {1,1,1}

                chromosomeText = (chromosome) ->
                    "#{table.concat(chromosome)} [#{fitnessMap[chromosome]}]"

                childToCrossover = {item.child, item.crossover for item in *matingResult}
                childToMutation = {item.child, item.mutation for item in *matingResult}

                with love.graphics
                    .printf "%d%%"\format(state_index), 10, 10, 100

                    for i, chromosome in ipairs population
                        .setColor i <= #matingPool and selectedColor or dropColor
                        .printf chromosomeText(chromosome), 10, 10 + i * 20, 100
                    
                    groupWidth = 200
                    .rectangle 'line', 200, 10, groupWidth, 25
                    elite = offspring[1]
                    eliteText = chromosomeText elite
                    .printf {selectedColor, eliteText}, 205, 15, 200

                    parent1Color = {1,1,0}
                    parent2Color = {1,1,1}
                    mutationColor = {1,0,0}
                   
                    coupleIndex = 1
                    for parent1, parent2 in eachCouple matingPool
                        child1 = offspring[2 + (coupleIndex - 1) * 2]
                        child2 = offspring[3 + (coupleIndex - 1) * 2]
                        crossover = childToCrossover[child1]

                        parentText = =>
                            M.thread(
                                @
                                => if crossover then M.tap M.clone(@), => table.insert @, crossover+1, '|' else @
                                M.concat                                    
                            )

                        childText = (leftColor, rightColor) =>
                            mutation = childToMutation[@]
                            bitColor = (i) ->
                                if mutation[i] == 1
                                    mutationColor
                                elseif crossover and i > crossover
                                    rightColor
                                else
                                    leftColor

                            [{bitColor(i), bit} for i, bit in ipairs @] |> M.flatten true
                    
                        x = 200
                        y = 40 + (coupleIndex - 1) * 55
                        h = 100

                        .rectangle 'line', x, y, groupWidth, 50
                        .setColor parent1Color
                        .printf parentText(parent1), x+5, y+5, h
                        .setColor parent2Color
                        .printf parentText(parent2), x+5, y+30, h
                        
                        .printf childText(child1, parent1Color, parent2Color), x+5+h, y+5, h
                        .printf childText(child2, parent2Color, parent1Color), x+5+h, y+30, h

                        coupleIndex += 1
                    
                    cellX, cellY = 500, 10
                    for i=1, #weights
                        weight = weights[i]
                        price = prices[i]
                        cellWidth = price * 10
                        cellHeight = weight * 15
                        mode = elite[i] == 1 and 'fill' or 'line'

                        .setColor 0,0,1
                        .rectangle mode, cellX, cellY, cellWidth, cellHeight
                        .setColor 1,1,1
                        .rectangle 'line', cellX, cellY, cellWidth, cellHeight
                        .printf "#{weight} kg", cellX+cellWidth+5, cellY+cellHeight/2-6, 100
                        .printf "¥ #{price}", cellX, cellY+cellHeight/2-6, cellWidth, 'center'
                        
                        cellY += cellHeight
                            
        @\addSprite algo

        algo\start!
        algo\runStep!
        algo\pause!

        @algo = algo
    
    keyreleased: (key) =>
        with @algo
            switch key
                when 'c'
                    \continue!
                when 'n'
                    \runStep! unless \isDone!
                when 'p'
                    \pause!
                when 'r'
                    \reset!
                    \start!
    
    switched: =>
        love.window.setTitle 'Genetic Algorithm'
        