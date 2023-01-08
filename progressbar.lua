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

    self.segments = {}

    self.segment_width = self.width / num_segments

    self.fraction_correct = 1

    return self
end

function progressbar:reset(num_segments)
    self.segments = {}
    self.fraction_correct = 1.0
    self.num_segments = num_segments
    self.segment_width = self.width / num_segments
end

function progressbar:draw()
    love.graphics.push("all")

        love.graphics.setColor(U.pallete_to_love(config.palette.black))

        -- Top and bottom lines
        love.graphics.rectangle("fill", self.x, self.y - 1, self.width, self.height + 2)

        -- Left and right lines
        love.graphics.rectangle("fill", self.x - 1, self.y, self.width + 2, self.height)

        for i, segment in ipairs(self.segments) do
            local color
            if segment then color = U.pallete_to_love(config.palette.green) else color = U.pallete_to_love(config.palette.red) end

            love.graphics.push("all")
                love.graphics.setColor(color)
                love.graphics.rectangle("fill", self.x + self.segment_width * (i - 1), self.y, self.segment_width, self.height)
            love.graphics.pop()
        end

    love.graphics.pop()

    love.graphics.push("all")

        love.graphics.setColor(U.pallete_to_love(config.palette.black))

        love.graphics.print(stringx.apply_template("$accuracy%", {
            accuracy = math.ceil(self.fraction_correct * 100)
        }), self.x + self.width + 2, self.y - 4)


    love.graphics.pop()
end

function progressbar:addSegment(correct)
    table.insert(self.segments, correct)

    local num_correct = 0
    for i, correct in ipairs(self.segments) do
        if correct then num_correct = num_correct + 1 end
    end

    self.fraction_correct = num_correct / #self.segments
end

return progressbar
