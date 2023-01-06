-- A base class for systems in the application, for syntactic sugar mostly.
local system = {}
system.__index = system

function system:group(groupname)
    return self.pool.groups[groupname].entities
end

function system:igroup(groupname)
    return ipairs(self:group(groupname))
end

function system:forgroup(groupname, func, filter)
    for _, e in self:igroup(groupname) do
        if filter and filter(e) then
            func(e)
        end
    end
end

function system.new()
    return setmetatable({}, system)
end

return system
