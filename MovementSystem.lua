local system = require"libraries.system"
local MovementSystem = system.new()

function MovementSystem:update(dt)
    self:forgroup("movers", function (e)
        e.x = e.x + e.speed
        e.y = e.y + e.speed
    end)
end

return MovementSystem
