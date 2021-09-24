local Sprite = require 'sprite'

local Algorithm = Sprite:subclass 'Algorithm'

local READY = 0
local RUNNING = 1
local PAUSED = 2
local DONE = 3

function Algorithm:initialize(config)
    Sprite.initialize(self, config)

    self.status = READY
end

function Algorithm:isDone()
    return self.status == DONE
end

function Algorithm:start()
    self.status = RUNNING
    self.elapsed = 0
    self.tick = nil
    self.step_co = coroutine.wrap(self.step)
    self.states = {}
end

function Algorithm:reset()
    self.status = READY
    self.states = {}
end

function Algorithm:runStep()
    local newState = self.step_co()
    if newState == nil then
        self.status = DONE
        self.step_co = nil
        local onComplete = self.onComplete
        if onComplete then
            onComplete()
        end
    else
        table.insert(self.states, newState)
        self.state_index = #self.states
    end
end

function Algorithm:pause()
    if self.status == RUNNING then
        self.status = PAUSED
    end
end

function Algorithm:continue()
    if self.status == PAUSED then
        self.status = RUNNING
    end
end

function Algorithm:update(dt)
    if self.status == RUNNING then
        self.elapsed = self.elapsed + dt
        local tick_duration = self.tick_duration or 0.2
        local tick = math.ceil(self.elapsed / tick_duration)
        if tick ~= self.tick then
            self.tick = tick
            self:runStep()
        end
    end
end

function Algorithm:draw()
    local states, state_index = self.states, self.state_index
    if states and state_index then
        local state = states[state_index]
        local drawState = self.drawState
        if state and drawState then
            self.drawState(state_index, state)
        end

        local drawStates = self.drawStates
        if drawStates then
            drawStates(states)
        end
    end
end

function Algorithm:notifyProgressChanged()
    local onProgressChanged = self.onProgressChanged
    if onProgressChanged then
        local progress = (self.state_index - 1) / (#self.states - 1)
        onProgressChanged(progress)
    end
end

function Algorithm:left()
    local state_index = self.state_index
    if self.state_index > 1 then
        self.state_index = self.state_index - 1
        self:notifyProgressChanged()
    end
end

function Algorithm:right()
    local state_index = self.state_index
    if self.state_index < #self.states then
        self.state_index = self.state_index + 1
        self:notifyProgressChanged()
    end
end

function Algorithm:setProgress(progress)
    local states = self.states
    if states then
        self.state_index = math.ceil(#states * progress)
    end
end

return Algorithm
