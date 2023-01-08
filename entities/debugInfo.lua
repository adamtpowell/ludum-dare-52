local debugInfo = {}
debugInfo.__index = debugInfo

function debugInfo:draw()
    print("Drawing")
    love.graphics.print("debugInfo", 0, 0)
end

function debugInfo.new()
    return setmetatable({}, debugInfo)
end

return debugInfo
