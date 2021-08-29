local Sprite = require 'sprite'

local Algorithm = Sprite:subclass 'Algorithm'

local READY = 0
local RUNNING = 1
local DONE = 2

function Algorithm:initialize(config)
    Sprite.initialize(self, config)

    self.status = READY
end

function Algorithm:start()
    self.status = RUNNING
    self.elapsed = 0
    self.tick = nil
    self.step_co = coroutine.wrap(self.step)
    self.states = {}
end

function Algorithm:update(dt)
    if self.status == RUNNING then
        self.elapsed = self.elapsed + dt
        local tick_duration = self.tick_duration or 0.2
        local tick = math.ceil(self.elapsed / tick_duration)
        if tick ~= self.tick then
            self.tick = tick

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
    end
end

function Algorithm:draw()
    local states, state_index, drawState = self.states, self.state_index,
                                           self.drawState
    if states and state_index then
        local state = states[state_index]
        if state then
            drawState(state_index, state)
        end
    end
end

function Algorithm:left()
    local state_index = self.state_index
    if self.state_index > 1 then
        self.state_index = self.state_index - 1
    end
end

function Algorithm:right()
    local state_index = self.state_index
    if self.state_index < #self.states then
        self.state_index = self.state_index + 1
    end
end

function Algorithm:setProgress(progress)
    local states = self.states
    if states then
        self.state_index = math.ceil(#states * progress)
    end
end

return Algorithm
