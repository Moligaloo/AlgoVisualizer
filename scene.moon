Sprite = require 'sprite'

with Sprite\subclass 'Scene'
    .initialize = (config) =>
        Sprite.initialize self, config
        @sprites = @sprites or {}
    
    .addSprite = (sprite) =>
        table.insert @sprites, sprite
        sprite
    
    .addSprites = (sprites) =>
        for sprite in *sprites 
            table.insert @sprites, sprite
    
    .mousepressed = (x,y) =>
        sprites = @sprites
        for i=#sprites, 1, -1 
            sprite = sprites[i]
            if sprite\mousepressed x,y
                return
    
    .mousemoved = (x,y) =>
        for sprite in *@sprites
            sprite\mousemoved x,y
    
    .mousereleased = =>
        for sprite in *@sprites 
            sprite\mousereleased!
    
    .update = (dt) =>
        for sprite in *@sprites
            sprite\update dt
        
    .draw = =>
        for sprite in *@sprites
            sprite\draw!
    
    .switched = =>

