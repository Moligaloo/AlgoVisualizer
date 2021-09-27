
defaultFont = nil

scenes = [(require name)! for name in *{'sa', 'aco', 'ga'}]
scene = scenes[2]

export love

with love
    .load = ->
        defaultFont = love.graphics.newFont 'kai.ttf'
        scene\switched!
    
    .mousepressed = (x,y) ->
        scene\mousepressed x,y
    
    .mousemoved = (x,y) ->
        scene\mousemoved x,y

    .mousereleased = ->
        scene\mousereleased
    
    .update = (dt) ->
        scene\update dt

    .keypressed = (key) ->
        index = tonumber key
        if index
            newScene = scenes[index]
            if newScene and scene != newScene
                scene = newScene
                scene\switched!
        elseif key == 'escape'
            love.event.quit 0
            
    .keyreleased = (key) ->
        scene\keyreleased key
    
    .draw = ->
        with love.graphics
            .setFont defaultFont
            .clear!
        scene\draw!
        

