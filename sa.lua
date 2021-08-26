local Sprite = require 'sprite'

local SA = Sprite:subclass 'SA'

local READY = 0
local RUNNING = 1
local FINISHED = 0

function SA:initialize(config)
    Sprite.initialize(self, config)

    self.state = READY
    self.tick_duration = 0.2
end

function SA:start(value)
    self.state = RUNNING
    self.elapsed = 0
end

function SA:update(dt)
    if self.state == RUNNING then
        self.elapsed = self.elapsed + dt
        local tick = math.ceil(self.elapsed / self.tick_duration)
        if tick ~= self.tick then
            self.tick = tick
        end
    end
end

function SA:draw()
    local tick = self.tick

    if tick then
        love.graphics.print(tostring(tick), 200, 200)
    end
end

return SA
