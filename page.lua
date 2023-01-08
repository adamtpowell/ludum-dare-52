
local config = require "config"
local card = require "card"
local stringx = require "libraries.batteries.stringx"

local page = {}
page.__index = page

function page.new(x, y, page, numpages)
    local self = setmetatable({}, page)

    self.x = x
    self.y = y
    self.page = page
    self.numpages = numpages

    return self
end

function page:draw()
    self.draw_page(self.x, self.y, self.page, self.numpages)
end

function page.draw_page(x, y, page, numpages, specimens, in_rotation)
    love.graphics.push("all")
        love.graphics.draw(Assets.book, x, y)

        love.graphics.push("all")
            love.graphics.setColor(U.pallete_to_love(config.palette.black))
            love.graphics.translate(x, y)

            love.graphics.print("Field Guide", 3, 1)

            local page_numbers = stringx.apply_template("$page/$numpages", {page = page, numpages = numpages})
            love.graphics.printf(page_numbers, 30, 1, 100, "center")
        love.graphics.pop()

        local offset = (1 + page - 1) * 2 - 1
        for i = 0, 1 do
            if i + offset > #specimens then
                break
            end
            local specimen = specimens[i + offset]
            local rotation = 0
            if i + offset == #specimens then
                rotation = in_rotation or 0
            end
            local is_new = in_rotation and i + offset == #specimens
            card.draw(x + config.layout.card_offset, config.layout.card_offset_y + y + i * config.layout.card_seperation, specimen, rotation, is_new)
        end

    love.graphics.pop()
end

return page
