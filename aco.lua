-- ant colony optimization
local Scene = require 'scene'
local Sprite = require 'sprite'
local _ = require 'underscore'
local Algorithm = require 'algorithm'
local class = require 'middleclass'

local Node = Sprite:subclass 'Node'
local ByteOfA = string.byte 'A'
local FarEnoughRadius = 60

function Node:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', self.x, self.y, 15, 100)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.label, self.x - 9, self.y - 8, 20, 'center')
end

function Node:distanceTo(another)
    local dx = self.x - another.x
    local dy = self.y - another.y
    return math.sqrt(dx * dx + dy * dy)
end

local function eachEdge(nodes)
    return coroutine.wrap(function()
        for i = 1, #nodes do
            for j = i + 1, #nodes do
                coroutine.yield(nodes[i], nodes[j])
            end
        end
    end)
end

local function eachMove(path)
    return coroutine.wrap(function()
        local n = #path
        for i = 1, n do
            local current = path[i]
            local next = i == n and path[1] or path[i + 1]
            coroutine.yield(current, next)
        end
    end)
end

Node.static.totalDistance = function(nodes)
    local sum = 0
    for a, b in eachMove(nodes) do
        sum = sum + a:distanceTo(b)
    end

    return sum
end

function Node:__concat(another)
    local a = self.label
    local b = another.label
    return a < b and a .. b or b .. a
end

-- ACO

local ACO = Scene:subclass 'ACO'

local function selectWithWeights(weights)
    local sum = _.reduce(weights, 0, function(a, b)
        return a + b
    end)
    local random = love.math.random()

    local accum = 0
    for index, weight in ipairs(weights) do
        accum = accum + weight / sum
        if random < accum then
            return index
        end
    end
end

function ACO:initialize(config)
    Scene.initialize(self, config)
    self:generate(10)
end

function ACO:startAlgorithm()
    self.algo = Algorithm {
        tick_duration = 0.02,
        step = function()
            local allNodes = self.nodes
            local pheromoneMatrix = {}
            local defaultPheromone = 0.1
            -- initialize pheromone matrix
            for a, b in eachEdge(allNodes) do
                pheromoneMatrix[a .. b] = defaultPheromone
            end

            local antCount = 2

            local function antMove()
                local path = {allNodes[1]}
                for j = 1, #allNodes - 1 do
                    local last = path[#path]
                    local neighbors = _.reject(allNodes, function(node)
                        return _.include(path, node)
                    end)
                    local weights = _.map(neighbors, function(neighbor)
                        local pheromone = pheromoneMatrix[last .. neighbor]
                        local visibility = 1 / last:distanceTo(neighbor)
                        return pheromone * visibility
                    end)

                    local nextNode = neighbors[selectWithWeights(weights)]
                    table.insert(path, nextNode)
                end

                return path
            end

            for i = 1, 200 do
                local paths = {}

                for j = 1, antCount do
                    local path = antMove()
                    table.insert(paths, path)
                end

                -- evaporate pheromone
                for a, b in eachEdge(allNodes) do
                    pheromoneMatrix[a .. b] = pheromoneMatrix[a .. b] * 0.9
                end

                -- accumulate delta pheromone for each ant
                for _, path in ipairs(paths) do
                    local totalDistance = Node.totalDistance(path)
                    local deltaPheromone = 1000 / totalDistance

                    for a, b in eachMove(path) do
                        pheromoneMatrix[a .. b] =
                            pheromoneMatrix[a .. b] + deltaPheromone
                    end
                end

                coroutine.yield(paths[1])
            end
        end,
        drawState = function(state_index, path)
            love.graphics.setColor(1, 1, 1, 0.5)
            for current, next in eachMove(path) do
                love.graphics.line(current.x, current.y, next.x, next.y)
            end
        end
    }

    self.algo:start()

    if self.sprites[1]:isInstanceOf(Algorithm) then
        self.sprites[1] = self.algo
    else
        table.insert(self.sprites, 1, self.algo)
    end
end

function ACO:addNode(x, y)
    local newNode = Node {
        x = x,
        y = y,
        label = string.char(ByteOfA + #self.nodes)
    }
    table.insert(self.nodes, self:addSprite(newNode))
end

function ACO:mousepressed(x, y)
    if self:farEnough(x, y) then
        self:addNode(x, y)
    end
end

function ACO:farEnough(x, y)
    local squaredDistance = FarEnoughRadius * FarEnoughRadius
    return _.all(self.nodes, function(node)
        local dx = x - node.x
        local dy = y - node.y
        local squaredSum = dx * dx + dy * dy
        return squaredSum >= squaredDistance
    end)
end

function ACO:generate(n)
    self.sprites = {}
    self.nodes = {}
    local margin = 50
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    for i = 1, n do
        local x, y
        repeat
            x = love.math.random(margin, width - margin)
            y = love.math.random(margin, height - margin)
        until self:farEnough(x, y)

        self:addNode(x, y)
    end
end

function ACO:keyreleased(key)
    if key == 'return' then
        self:startAlgorithm()
    elseif key == 'c' then
        self.sprites = {}
        self.nodes = {}
    elseif key == 'g' then
        self:generate(10)
    end
end

function ACO:switched()
    love.window.setTitle 'Ant Colony Optimization'
end

return ACO

