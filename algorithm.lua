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
            else
                table.insert(self.states, newState)
            end
        end
    end
end

function Algorithm:getStateByProgress(progress)
    local states = self.states
    if states then
        return states[math.floor(#states * progress)]
    end
end

return Algorithm
