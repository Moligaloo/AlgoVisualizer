Sprite = require 'sprite'

READY = 0
RUNNING = 1
PAUSED = 2
DONE = 3

with Sprite\subclass 'Algorithm'
    .initialize = (config) =>
        Sprite.initialize self, config
        @status = READY
    
    .isDone = =>
        @status == DONE

    .start = =>
        @status = RUNNING
        @elapsed = 0
        @tick = nil
        @step_co = coroutine.wrap @step
        @states = {}
    
    .reset = =>
        @status = READY
        @states = {}
    
    .runStep = =>
        newState = @step_co!
        if newState == nil
            @status = DONE
            @step_co = nil
            if @onComplete
                @onComplete!
        else
            table.insert @states, newState
            @state_index = #@states

    .pause = =>
        @status = PAUSED if @status == RUNNING
    
    .continue = =>
        @status = RUNNING if @status == PAUSED
        
    .update = (dt) =>
        if @status == RUNNING
            @elapsed += dt
            tick_duration = @tick_duration or 0.2
            tick = math.ceil @elapsed / tick_duration
            if tick != @tick 
                @tick = tick
                self\runStep!
    
    .draw = =>
        states, state_index = @states, @state_index
        if states and state_index
            state = states[state_index]
            drawState = @drawState
            if state and drawState
                drawState(state_index, state)

            @drawStates states if @drawStates
        
    .notifyProgressChanged = =>
        onProgressChanged = @onProgressChanged
        if onProgressChanged
            progress = (@state_index - 1) / (#@states - 1)
            onProgressChanged progress
    
    .left = =>
        if @state_index > 1
            @state_index -= 1
            self\notifyProgressChanged!
    
    .right = =>
        if @state_index < #@states
            @state_index += 1
            self\notifyProgressChanged!

    .setProgress = (progress) =>
        if @states
            @state_index = math.ceil(#@states * progress)