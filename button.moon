Sprite = require 'sprite'

with Sprite\subclass 'Button'
    .initialize = (config) =>
        Sprite.initialize self, config
        @width = 80
        @height = 30
    
    .draw = =>
        blueColor = {0, 53 / 255, 106 / 255}
        whiteColor = {1, 1, 1}
        blackColor = {0, 0, 0}

        with love.graphics
            .setColor @hovered and blueColor or blackColor
            .rectangle 'fill', @x, @y, @width, @height, 4, 4
            .setColor whiteColor
            .rectangle 'line', @x, @y, @width, @height, 4, 4
            .printf @text, @x, @y+7, @width, 'center'
        
    .mousemoved = (x,y) =>
        @hovered = self\isHit x,y
    
    .mousereleased = =>
        @onClick! if @hovered and @onClick
    
    .mousepressed = => @hovered
    