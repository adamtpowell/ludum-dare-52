local config = require "config"
local stringx = require "libraries.batteries.stringx"

local progressbar = {}
progressbar.__index = progressbar

function progressbar.new(x, y, width, height, num_segments)
    local self = setmetatable({}, progressbar)

    self.width = width
    self.height = height
    self.x = x
    self.y = y

    self.life = config.gameplay.starting_life

    return self
end

function progressbar:getLife()
    return self.life
end

function progressbar:changeLife(delta)
    self.life = self.life + delta
    if self.life > config.gameplay.starting_life then
        self.life = 100
    end

end

function progressbar:reset(num_segments)
    self.life = config.gameplay.starting_life
end

function progressbar:draw()
    love.graphics.push("all")

        love.graphics.setColor(U.pallete_to_love(config.palette.black))

        -- Top and bottom lines
        love.graphics.rectangle("fill", self.x, self.y - 1, self.width, self.height + 2)

        -- Left and right lines
        love.graphics.rectangle("fill", self.x - 1, self.y, self.width + 2, self.height)

        love.graphics.setColor(U.pallete_to_love(config.palette.green))

        love.graphics.rectangle("fill", self.x, self.y, self.width * (self.life / config.gameplay.starting_life), self.height)

    love.graphics.pop()

    -- love.graphics.push("all")

    --     love.graphics.setColor(U.pallete_to_love(config.palette.black))

    --     love.graphics.print(stringx.apply_template("$accuracy%", {
    --         accuracy = math.ceil(self.fraction_correct * 100)
    --     }), self.x + self.width + 2, self.y - 4)


    -- love.graphics.pop()
end

return progressbar
