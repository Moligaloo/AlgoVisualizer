local Sprite = require 'sprite'

local Coordination = Sprite:subclass 'Coordination'

local function logic_to_graph(logic_x, logic_y)
    return logic_x and (love.graphics.getWidth() / 2 + logic_x),
           logic_y and love.graphics.getHeight() / 2 - logic_y

end

local function graph_to_logic(x, y)
    return x and x - love.graphics.getWidth() / 2,
           y and love.graphics.getHeight() / 2 - y
end

function Coordination:initialize(config)
    Sprite.initialize(self, config)
    self.points = nil
    self.inserting = false
end

function Coordination:mousepressed(x, y)
    self.points = {x, y}
    self.inserting = true

    return self.inserting
end

function Coordination:mousemoved(x, y)
    local inserting = self.inserting
    local points = self.points

    if inserting then
        local valid = true
        for i = 1, #points, 2 do
            if points[i] > x then
                valid = false
                break
            end
        end

        if valid then
            table.insert(points, x)
            table.insert(points, y)
        end
    end
end

function Coordination:mousereleased()
    self.inserting = false
end

local function draw_label(logic_x, logic_y)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local x = logic_x + screenWidth / 2
    local y = screenHeight / 2 - logic_y

    if x < 0 or x > screenWidth or y < 0 or y > screenHeight then
        return false
    else
        love.graphics.circle('fill', x, y, 2)

        if logic_y == 0 then
            love.graphics.print(tostring(logic_x), x, y)
        else
            love.graphics.print(tostring(logic_y), x, y)
        end

        return true
    end
end

local function draw_labels(dx, dy)
    local logic_x = dx
    local logic_y = dy
    while draw_label(logic_x, logic_y) do
        logic_x = logic_x + dx
        logic_y = logic_y + dy
    end
end

local function draw_coordination_axis()
    draw_label(0, 0)
    draw_labels(50, 0)
    draw_labels(-50, 0)
    draw_labels(0, 50)
    draw_labels(0, -50)
end

function Coordination:draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(0, screenHeight / 2, screenWidth, screenHeight / 2)
    love.graphics.line(screenWidth / 2, 0, screenWidth / 2, screenHeight)

    love.graphics.setColor(1, 1, 1)

    draw_coordination_axis()

    local points = self.points
    if points and #points >= 4 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.line(points)
    end
end

function Coordination:mapToLogic(x, y)
    return graph_to_logic(x, y)
end

function Coordination:mapToGraph(logic_x, logic_y)
    return logic_to_graph(logic_x, logic_y)
end

function Coordination:getValue(logic_x)
    local x = logic_to_graph(logic_x)

    local points = self.points
    if points and #points >= 4 then
        for i = 1, #points - 3, 2 do
            local x0 = points[i]
            local x1 = points[i + 2]
            if x >= x0 and x <= x1 then
                local y0 = points[i + 1]
                local y1 = points[i + 3]
                -- https://zh.wikipedia.org/wiki/%E7%BA%BF%E6%80%A7%E6%8F%92%E5%80%BC
                local y = y0 + (x - x0) * (y1 - y0) / (x1 - x0)
                return select(2, graph_to_logic(nil, y))
            end
        end
    end
end

function Coordination:getRandomX()
    local points = self.points
    if points and #points >= 4 then
        local i = love.math.random(1, #points - 1)
        if i % 2 == 0 then
            i = i - 1
        end

        return points[i]
    end
end

function Coordination:getRandomPoint()
    return self:mapToLogic(self:getRandomX())
end

return Coordination
