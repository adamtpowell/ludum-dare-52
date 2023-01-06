local system = require "libraries.system"
local DebugDrawSystem = system.new()

function DebugDrawSystem:draw()
    self:forgroup("debugVisible", function (e)
        love.graphics.print("object", e.x, e.y)
    end)
end

return DebugDrawSystem
