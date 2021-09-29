Sprite = require 'sprite'
M = require 'moses'

import random from love.math

class Coordination extends Sprite
    new: (config) =>
        super config
        @points = nil
        @inserting = false
        @enabled = true

    isReady: =>
        @points and next @points
    
    mousepressed: (x,y) =>
        return false unless @enabled

        @points = {x,y}
        @inserting = true

        @inserting

    mousemoved: (x,y) =>
        inserting = @inserting
        points = @points

        if inserting
            valid = true
            for i=1, #points, 2 
                if points[i] > x
                    valid = false
                    break
            
            if valid
                M.push points, x, y
        else
            logic_x = @\mapToLogic x
            logic_y = @\getValue logic_x
            if logic_x and logic_y
                @pointee = {logic_x, logic_y}
        
    mousereleased: =>
        @inserting = false

    drawLabels: (dx, dy) =>
        logic_x = dx
        logic_y = dy
        while @\drawLabel logic_x, logic_y
            logic_x += dx
            logic_y += dy

    drawLabel: (logic_x, logic_y) =>
        return false if logic_x > @width or logic_y > @height
        
        x,y = @\mapToGraph logic_x, logic_y
        with love.graphics
            .circle 'fill', x, y, 2
            .print (logic_y == 0 and logic_x or logic_y), x, y

        true
            
    draw: =>
        with love.graphics
            .setColor 1,1,1,0.5
            .line @x, @y, @x+@width, @y
            .line @x, @y, @x, @y-@height
            
            .setColor 1,1,1
            @\drawLabel 0,0
            @\drawLabels 50,0
            @\drawLabels 0,50

            points = @points
            if points and #points >= 4
                .setColor 1,1,1
                .line points
                pointee = @pointee
                if pointee
                    {logic_x, logic_y} = pointee
                    x,y = @\mapToGraph logic_x, logic_y
                    .circle 'fill', x, y, 4
                    .printf ("(%.2f, %.2f)")\format(logic_x, logic_y), x, y, 100, 'center'

    mapToLogic: (x,y) =>
        x and x-@x, y and @y-y
    
    mapToGraph: (logic_x, logic_y) =>
        logic_x and @x + logic_x, logic_y and @y - logic_y
    
    getValue: (logic_x) =>
        x = @\mapToGraph logic_x

        points = @points
        if points and #points >= 4
            for i=1, #points-3,2
                x0,x1 = points[i],points[i+2]
                if x>=x0 and x<=x1 
                    y0,y1 = points[i + 1],points[i + 3]
                    -- https://zh.wikipedia.org/wiki/%E7%BA%BF%E6%80%A7%E6%8F%92%E5%80%BC
                    y = y0 + (x - x0) * (y1 - y0) / (x1 - x0)
                    return select(2, @\mapToLogic(nil, y))

    getRandomX: =>
        points = @points
        if points and #points >= 4
            points[1+(random(#points/2)-1)*2]
    
    getRandomPoint: =>
        @\mapToLogic @\getRandomX!

    randomShift: (point, offset) =>
        while true
            newPoint = point + random(-offset, offset)
            if @\getValue newPoint
                return newPoint