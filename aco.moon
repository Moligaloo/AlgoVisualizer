-- ant colony optimization

Scene = require 'scene'
Sprite = require 'sprite'
M = require 'moses'
Algorithm = require 'algorithm'
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
        @\generate 10
        @drawPheromone = true

    startAlgorithm: =>
        @algo = Algorithm
            tick_duration: 0.02
            step: ->
                allNodes = @nodes
                defaultPheromone = 0
                antCount = 10  
                alpha = 1
                beta = 2

                evaporate = (pheromone) -> pheromone * 0.9

                -- initialize pheromone matrix
                pheromoneMatrix = { a..b, defaultPheromone for a,b in eachEdge allNodes}
                
                antMove = ->
                    createPath allNodes, (current, candidates) ->
                        weights = for candidate in *candidates
                            pheromone = pheromoneMatrix[current..candidate]
                            visibility = 1/current\distanceTo(candidate)
                            pheromone^alpha * visibility^beta
                            
                        candidates[selectWithWeights weights]

                for i=1, 200
                    path = nil 

                    -- evaporate pheromone and accumulate new ants' deposited pheromone
                    pheromoneMatrix = [antMove! for i=1, antCount]
                        |> M.map (path) -> {:path, distance: Node.totalDistance path}
                        |> M.tap (pairs) -> path = M.best(pairs, (a,b) -> a.distance < b.distance).path
                        |> M.map (pair) ->
                            deltaPheromone = 1000 / pair.distance
                            [{a..b, deltaPheromone} for a,b in eachMove pair.path]
                        |> M.flatten true
                        |> M.reduce(
                            (matrix, item) ->
                                {edge, deltaPheromone} = item
                                with matrix
                                    matrix[edge] += deltaPheromone
                            pheromoneMatrix |> M.map evaporate
                        )

                    yield
                        :path
                        :pheromoneMatrix

            drawState: (state_index, state) ->
                {:path, :pheromoneMatrix} = state

                with love.graphics
                    .setLineWidth 10

                    if @drawPheromone
                        for a,b in eachEdge @nodes
                            pheromone = pheromoneMatrix[a..b]
                            alpha = pheromone/50
                            .setColor 52 / 255, 120 / 255, 246 / 255, alpha
                            .line a.x, a.y, b.x, b.y
                    
                    .setColor 1,1,1
                    .setLineWidth 1
                    for current, next in eachMove path 
                        .line current.x, current.y, next.x, next.y
                    
                    .setColor 1,0,0 if @algo\isDone!    
                    
                    maxPheromone = M.max pheromoneMatrix
                    .printf "Step: #{state_index} Max Pheromone: #{maxPheromone}", 0, 0, 500

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
        table.insert @nodes, @\addSprite newNode

    mousepressed: (x,y) =>
        if @algo == nil and @\farEnough(x,y) 
            @\addNode x,y

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
                if @\farEnough x,y 
                    break
            @\addNode x,y

    keyreleased: (key) =>
        switch key
            when 'return'
                @\startAlgorithm!
            when 'c'
                @algo\continue! if @algo
            when 'g'
                @\generate 10
            when 'n'
                @algo\runStep!
            when 'p'
                @drawPheromone = not @drawPheromone

    switched: =>
        love.window.setTitle 'Ant Colony Optimization'

