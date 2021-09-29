-- simulated annealing algorithm

Scene = require 'scene'
Coordination = require 'coordination'
Algorithm = require 'algorithm'
M = require 'moses'

import yield from coroutine
import random, exp from math

class SA extends Scene
    new: (config) =>
        super config
        coord = Coordination
            x: 20
            y: love.graphics.getHeight! / 2 - 20
            width: love.graphics.getWidth! - 40
            height: love.graphics.getHeight! / 2 - 40
        
        algo = Algorithm
            step: -> 
                getEnergy = (point) -> coord\getValue point
                cooldown = (temperature) -> temperature * 0.9

                point = coord\getRandomPoint!
                temperature = 1000
                while temperature > 1
                    energy = getEnergy point
                    newPoint = coord\randomShift point, 200
                    newEnergy = getEnergy newPoint
                    delta = newEnergy - energy
                    probability = exp(-delta/temperature)
                    transited = delta < 0 or random! < probability

                    yield {
                        point
                        newPoint
                        energy
                        newEnergy
                        temperature
                        probability
                        transited
                    }

                    temperature = cooldown temperature
                    if transited
                        point = newPoint
            
            drawState: (state_index, state) ->
                { point, newPoint, energy, newEnergy, temperature, probability } = state
                delta = newEnergy - energy

                with love.graphics
                    currentX = coord\mapToGraph point
                    .setColor 1,0,0
                    .line currentX, coord.y-200, currentX, coord.y
                    newX = coord\mapToGraph newPoint
                    .setColor 0,1,0
                    .line newX, coord.y-200, newX, coord.y

                    .setColor 1,1,1
                    text = ("步骤: %d\n温度: %.2f K\n点: %d -> %d\n转移概率: %.2f%%\n能量: %.2f -> %.2f (%.2f)")\format(
                        state_index,
                        temperature,
                        point,
                        newPoint,
                        probability * 100,
                        energy,
                        newEnergy,
                        delta
                    )
                    .printf text, .getWidth!-250, 10, 250, 'left'

            drawStates: (states) =>
                return if states == nil or #states < 2
                
                with love.graphics
                    temperaturePoints = {}
                    energyPoints = {}
                    newEnergyPoints = {}
                    origin_x = 20
                    origin_y = .getHeight! - 20
                    height = .getHeight!/2 - 40

                    for i,state in ipairs states
                        temperature = state[5]
                        ratio = temperature / 1000
                        x = origin_x + i*10
                        y = origin_y - height*ratio
                        
                        M.push temperaturePoints, x, y
                        
                        energy = state[3]
                        M.push energyPoints, x, origin_y - energy

                        newEnergy = state[4]
                        M.push newEnergyPoints, x, origin_y-newEnergy
                    
                    .setColor 1,1,1
                    .line temperaturePoints
                    .setColor 1,0,0
                    .line energyPoints
                    .setColor 0,1,0
                    .line newEnergyPoints

        @coord = coord
        @algo = algo

        @\addSprites{coord, algo}
    
    keyreleased: (key) =>
        switch key
            when 'return'
                if @coord\isReady!
                    @algo\start!
                    @coord.enabled = false
            when 'left'
                @algo\left!
            when 'right'
                @algo\right!
            when 'r'
                @algo\reset!
                @coord.enabled = true
    
    switched: =>
        love.window.setTitle 'Simulated Annealing'
                        