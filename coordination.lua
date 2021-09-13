local Sprite = require 'sprite'

local Coordination = Sprite:subclass 'Coordination'

function Coordination:initialize(config)
    Sprite.initialize(self, config)
    self.points = nil
    self.inserting = false
    self.enabled = true
end

function Coordination:mousepressed(x, y)
    if not self.enabled then
        return false
    end

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
    else
        local logic_x = self:mapToLogic(x)
        local logic_y = self:getValue(logic_x)
        if logic_x and logic_y then
            self.pointee = {logic_x, logic_y}
        end
    end
end

function Coordination:mousereleased()
    self.inserting = false
end

function Coordination:drawLabels(dx, dy)
    local logic_x = dx
    local logic_y = dy
    while self:drawLabel(logic_x, logic_y) do
        logic_x = logic_x + dx
        logic_y = logic_y + dy
    end
end

function Coordination:drawLabel(logic_x, logic_y)
    if logic_x > self.width or logic_y > self.height then
        return false
    end

    local x, y = self:mapToGraph(logic_x, logic_y)
    love.graphics.circle('fill', x, y, 2)
    if logic_y == 0 then
        love.graphics.print(tostring(logic_x), x, y)
    else
        love.graphics.print(tostring(logic_y), x, y)
    end

    return true
end

function Coordination:draw()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(self.x, self.y, self.x + self.width, self.y)
    love.graphics.line(self.x, self.y, self.x, self.y - self.height)

    love.graphics.setColor(1, 1, 1)

    self:drawLabel(0, 0)
    self:drawLabels(50, 0)
    self:drawLabels(0, 50)

    local points = self.points
    if points and #points >= 4 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.line(points)

        local pointee = self.pointee
        if pointee then
            local logic_x, logic_y = pointee[1], pointee[2]
            local x, y = self:mapToGraph(logic_x, logic_y)
            love.graphics.circle('fill', x, y, 4)
            love.graphics.printf(("(%.2f, %.2f)"):format(logic_x, logic_y), x,
                                 y, 100, 'center')
        end
    end
end

function Coordination:mapToLogic(x, y)
    return x and x - self.x, y and self.y - y
end

function Coordination:mapToGraph(logic_x, logic_y)
    return logic_x and self.x + logic_x, logic_y and self.y - logic_y
end

function Coordination:getValue(logic_x)
    local x = self:mapToGraph(logic_x)

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
                return select(2, self:mapToLogic(nil, y))
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

function Coordination:randomShift(point, offset)
    local newPoint
    repeat
        newPoint = point + love.math.random(-offset, offset)
    until self:getValue(newPoint)
    return newPoint
end

return Coordination
