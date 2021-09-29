M = require 'moses'

class Sprite
    new: (config) =>
        @x = 0
        @y = 0
        @width = 0
        @height = 0
        
        if config
            M.extend @, config
    
    mousepressed: (x,y) => 
        @\isHit x,y
    
    mousemoved: (x,y) =>
    mousereleased: (x,y) =>
    draw: =>
    isHit: (x,y) =>
        x > @x and x <= @x+@width and y >= @y and y <= @y+@height
    
    update: (dt) =>
    keyreleased: (key) =>
