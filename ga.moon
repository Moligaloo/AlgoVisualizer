-- genetic algorithm

Scene = require 'scene'
Algorithm = require 'algorithm'
M = require 'moses'

export love

import yield from coroutine
import random from love.math

randomBit = -> random 0,1
randomBits = (length) -> [randomBit! for i=1, length]

eachCouple = (pool) ->
    coroutine.wrap( ->
        for i=1, #pool-1
            for j=i+1, #pool
                yield pool[i], pool[j]
    )

class GA extends Scene
    new: (config) =>
        super config

        weights = {2, 1, 6, 1, 4, 9, 5, 8, 3}
        prices = {5, 3, 15, 5, 6, 18, 8, 20, 8}
        maxWeight = 25

        getFitness = (chromosome) ->
            totalPrice, totalWeight = 0,0
            for i, bit in ipairs chromosome
                if bit == 1
                    totalPrice += prices[i]
                    totalWeight += weights[i]
            
            if totalWeight <= maxWeight then totalPrice else 0
        
        algo = Algorithm 
            tick_duration: 0.02
            step: ->
                populationSize = 21
                matingPoolSize = 5
                chromosomeLength = #weights
                crossoverRate = 0.8
                mutationRate = 0.1

                population = [randomBits(chromosomeLength) for i=1, populationSize]
                
                mate = (parent1, parent2) ->
                    point = if random! < crossoverRate then random chromosomeLength else nil
                    result = {}
                    for permutation in M.permutation {parent1, parent2}
                        {p1, p2} = permutation
                        child = nil
                        if point 
                            child = M.append M.head(p1, point), M.last(p2, #p2-point) 
                        else 
                            child = p1

                        mutation = nil
                        child = M.map(child, (bit, i) ->
                            if random! < mutationRate
                                mutation = {} if mutation == nil
                                mutation[i] = true
                                if bit == 0 then 1 else 0
                            else
                                bit
                        )
                        
                        result[child] = 
                            crossover: point
                            :mutation
                    result
                
                for i=1, 100 
                    fitnessMap = {chromosome, getFitness(chromosome) for chromosome in *population}
                    M.sort population, (a,b)-> fitnessMap[a]>fitnessMap[b]

                    matingPool = M.head population, matingPoolSize
                    elite = matingPool[1]

                    matingResult = {}
                    for parent1, parent2 in eachCouple matingPool
                        M.extend(matingResult, mate(parent1, parent2))

                    offspring = M.append {elite}, M.keys matingResult
                
                    yield
                        :population
                        :matingPool
                        :offspring
                        :fitnessMap
                        :matingResult
                    
                    population = offspring

            drawState: (state_index, state) ->
                {:population, :matingPool, :offspring, :fitnessMap, :matingResult} = state

                selectedColor = {0,1,0}
                dropColor = {1,1,1}

                chromosomeText = (chromosome) ->
                    "#{table.concat(chromosome)} [#{fitnessMap[chromosome]}]"

                with love.graphics
                    .printf "%d%%"\format(state_index), 10, 10, 100

                    for i, chromosome in ipairs population
                        .setColor i <= 5 and selectedColor or dropColor
                        .printf chromosomeText(chromosome), 10, 10 + i * 20, 100
                    
                    groupWidth = 200
                    .rectangle 'line', 200, 10, groupWidth, 25
                    elite = offspring[1]
                    eliteText = chromosomeText elite
                    .printf {selectedColor, eliteText}, 205, 15, 200

                    parent1Color = {1,1,0}
                    parent2Color = {1,1,1}

                    coupleIndex = 1
                    for parent1, parent2 in eachCouple matingPool
                        child1 = offspring[2 + (coupleIndex - 1) * 2]
                        child2 = offspring[3 + (coupleIndex - 1) * 2]
                        crossover = matingResult[child1].crossover

                        parentText = (parent) ->
                            if crossover
                                copy = M.clone parent
                                table.insert copy, crossover+1, '|'
                                table.concat copy
                            else
                                table.concat parent

                        childText = (child, parentNo) ->
                            mutation = matingResult[child].mutation
                            colored = {}

                            leftColor, rightColor = parent1Color, parent2Color
                            if parentNo == 2
                                leftColor, rightColor = parent2Color, parent1Color

                            normalColor = leftColor
                            mutationColor = {1,0,0}
                            for i, bit in ipairs child 
                                mutated = mutation and mutation[i]
                                color = mutated and mutationColor or normalColor
                                M.push colored, color, bit
                                if i == crossover
                                    normalColor = rightColor
                            
                            colored
                    
                        x = 200
                        y = 40 + (coupleIndex - 1) * 55
                        h = 100

                        .rectangle 'line', x, y, groupWidth, 50
                        .setColor parent1Color
                        .printf parentText(parent1), x+5, y+5, h
                        .setColor parent2Color
                        .printf parentText(parent2), x+5, y+30, h
                        
                        .printf childText(child1, 1), x+5+h, y+5, h
                        .printf childText(child2, 2), x+5+h, y+30, h

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
                
            
        
        self\addSprite algo

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
        