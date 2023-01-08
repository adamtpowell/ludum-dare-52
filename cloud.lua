local cloud = {}
cloud.__index = cloud

function cloud.new()
    local self = setmetatable({}, cloud)



    return self
end

return cloud
