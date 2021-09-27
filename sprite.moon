M = require 'moses'
middleclass = require 'middleclass'

with middleclass 'Sprite'
    .initialize = (config) =>
        @x = 0
        @y = 0
        @width = 0
        @height = 0
        
        if config
            M.extend self, config
    
    .mousepressed = (x,y) => 
        self\isHit x,y
    
    .mousemoved = (x,y) =>
    .mousereleased = (x,y) =>
    .draw = =>
    .isHit = (x,y) =>
        x > @x and x <= @x+@width and y >= @y and y <= @y+@height
    
    .update = (dt) =>
    .keyreleased = (key) =>
