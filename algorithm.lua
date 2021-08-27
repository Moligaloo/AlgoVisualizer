local Sprite = require 'sprite'

local Algorithm = Sprite:subclass 'Algorithm'

local READY = 0
local RUNNING = 1
local DONE = 2

function Algorithm:initialize(config)
    Sprite.initialize(self, config)

    self.state = READY
end

function Algorithm:start()
    self.state = RUNNING
    self.elapsed = 0
    self.tick = nil
    self.step_co = coroutine.wrap(self.step)
end

function Algorithm:update(dt)
    if self.state == RUNNING then
        self.elapsed = self.elapsed + dt
        local tick_duration = self.tick_duration or 0.2
        local tick = math.ceil(self.elapsed / tick_duration)
        if tick ~= self.tick then
            self.tick = tick

            local point = self.step_co()
            if point == nil then
                self.state = DONE
            end
        end
    end
end

return Algorithm
