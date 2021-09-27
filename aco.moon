-- ant colony optimization

Scene = require 'scene'
Sprite = require 'sprite'
M = require 'moses'
Algorithm = require 'algorithm'

export love

ByteOfA = string.byte 'A'
FarEnoughRadius = 60

import yield from coroutine
import random from love.math

eachEdge = (nodes) ->
    coroutine.wrap -> 
        for i=1, #nodes-1
            for j=i+1, #nodes
                yield nodes[i], nodes[j]

eachMove = (path) ->
    coroutine.wrap ->
        n = #path
        for i=1, n
            yield path[i], if i == n then path[1] else path[i+1]

minusSet = (allArray, exceptArray) ->
    exceptSet = {value, true for value in *exceptArray}
    M.reject allArray, (value) -> exceptSet[value]

createPath = (allNodes, pick) ->
    path = {allNodes[1]}
    while #path != #allNodes
        candidates = minusSet allNodes, path
        table.insert path, pick(path[#path], candidates)
    path

selectWithWeights = (weights) ->
    sum = M.sum weights
    return random(#weights) if sum == 0
         
    r = random!
    accum = 0
    for index, weight in ipairs weights
        accum += weight/sum
        if r < accum 
            return index

class Node extends Sprite
    draw: =>
        with love.graphics
            .setColor 1, 1, 1
            .circle 'fill', @x, @y, 15, 100
            .setColor 0, 0, 0
            .printf @label, @x - 9, @y - 8, 20, 'center' 

    distanceTo: (another) =>
        dx = @x - another.x
        dy = @y - another.y
        math.sqrt(dx*dx + dy*dy)

    __concat: (another) =>
        a = @label
        b = another.label
        a < b and a..b or b..a

    @totalDistance: (nodes) ->
        M.sum [a\distanceTo(b) for a,b in eachMove nodes]
            

class ACO extends Scene
    new: (config) =>
        super config
        self\generate 10

    startAlgorithm: =>
        @algo = Algorithm
            tick_duration: 0.02
            step: ->
                allNodes = @nodes
                pheromoneMatrix = {}
                defaultPheromone = 0
                antCount = 10  
                alpha = 1
                beta = 2

                -- initialize pheromone matrix
                for a, b in eachEdge allNodes
                    pheromoneMatrix[a..b] = defaultPheromone
                
                antMove = ->
                    createPath allNodes, (current, candidates) ->
                        getWeight = (candidate) ->
                            pheromone = pheromoneMatrix[current..candidate]
                            visibility = 1/current\distanceTo(candidate)
                            pheromone^alpha * visibility^beta

                        weights = [getWeight(candidate) for candidate in *candidates]
                        candidates[selectWithWeights weights]

                for i=1, 200
                    -- create paths from ants
                    paths = [antMove! for _=1, antCount]

                    -- calculate ants' deposited pheromone
                    delta = M(paths)\map(
                            (path) ->
                                totalDistance = Node.totalDistance path
                                deltaPheromone = 1000 / totalDistance
                                [{a..b, deltaPheromone} for a,b in eachMove path]
                        )\flatten(true)\reduce(
                            (matrix, item) ->
                                {key, value} = item
                                matrix[key] = (matrix[key] or 0) + value 
                                matrix
                            {}
                        )\value!
                    
                    -- evaporate pheromone and accumulate new deposited pheromone
                    pheromoneMatrix = M.map(pheromoneMatrix, (pheromone, edge) -> pheromone*0.9+(delta[edge] or 0))

                    yield
                        path: paths[1]
                        :pheromoneMatrix

            drawState: (state_index, state) ->
                {:path, :pheromoneMatrix} = state

                with love.graphics
                    .setLineWidth 10

                    for a,b in eachEdge @nodes
                        pheromone = pheromoneMatrix[a..b]
                        alpha = pheromone/50
                        .setColor 52 / 255, 120 / 255, 246 / 255, alpha
                        .line a.x, a.y, b.x, b.y
                    
                    .setColor 1,1,1
                    .setLineWidth 1
                    for current, next in eachMove path 
                        .line current.x, current.y, next.x, next.y
                    
                    if @algo\isDone!
                        .setColor 1,0,0
                    
                    maxPheromone = M.max pheromoneMatrix
                    .printf "Max Pheromone: #{maxPheromone}", 0, 0, 500

        @algo\start!

        if @sprites[1].__class == Algorithm
            @sprites[1] = @algo
        else
            table.insert @sprites, 1, @algo

    addNode: (x,y) =>
        newNode = Node
            :x
            :y
            label: string.char(ByteOfA + #@nodes)
        table.insert @nodes, self\addSprite newNode

    mousepressed: (x,y) =>
        if @algo == nil and self\farEnough(x,y) 
            self\addNode x,y

    farEnough: (x,y) =>
        squaredDistance = FarEnoughRadius * FarEnoughRadius
        M.all @nodes, (node) ->
            dx = x - node.x
            dy = y - node.y
            dx*dx + dy*dy >= squaredDistance

    generate: (n) =>
        @sprites = {}
        @nodes = {}
        margin = 50
        width = love.graphics.getWidth!
        height = love.graphics.getHeight!

        for i=1, n 
            x, y = 0, 0
            while true
                x = random margin, width - margin
                y = random margin, height - margin
                if self\farEnough x,y 
                    break
            self\addNode x,y

    keyreleased: (key) =>
        switch key
            when 'return'
                self\startAlgorithm!
            when 'c'
                @algo\continue! if @algo
            when 'g'
                self\generate 10
            when 'n'
                @algo\runStep!

    switched: =>
        love.window.setTitle 'Ant Colony Optimization'

