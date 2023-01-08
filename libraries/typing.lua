function is(variable, goal_type)
    if type(goal_type) == "string" then
        return type(variable) == goal_type
    else
        if variable == nil then
            return false
        end
        local mt = getmetatable(variable)
        if mt == goal_type then
            return true -- This variable has the goal metatable.
        else
            return is(mt, goal_type) -- Ascend the metatable tree
        end

    end
end

-- Assert that the function is goal type.
function __(variable, goal_type)
    assert(is(variable, goal_type))
    return variable
end

-- Assert that the variable is ether goal type or nil
function __optional(variable, goal_type)
    assert(variable == nil or is(variable, goal_type))
    return variable
end

-- Check that each element matches the goal type.
function __elements(variable, goal_type)
    for i, element in ipairs(variable) do
        __(element, goal_type)
    end
    return variable
end

-- Assert that each element matches the goal type or is nil.
function __optional_elements(variable, goal_type)
    for i, element in ipairs(variable) do
        __optional(element, goal_type)
    end
    return variable
end

-- Assert that each element is not the goal type.
function __not_elements(variable, goal_type)
    for i, element in ipairs(variable) do
        __not(element, goal_type)
    end
    return variable
end

-- Assert that the variable is not the goal type.
function __not(variable, goal_type)
    if goal_type == nil then
        print("Goal was nil", variable ~= nil)
        assert(variable ~= nil)
        return
    end
    assert(not is(variable, goal_type))
    return variable
end
