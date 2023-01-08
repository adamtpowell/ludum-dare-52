
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

function page.draw_page(x, y, page, numpages, specimens, in_rotation, title)
    love.graphics.push("all")
        if numpages > 2 then love.graphics.draw(title and Assets.book_title or Assets.book, x + 4, y + 4)end
        if numpages > 1 then love.graphics.draw(title and Assets.book_title or Assets.book, x + 2, y + 2) end
        love.graphics.draw(title and Assets.book_title or Assets.book, x, y)

        if not title then
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
        else
            love.graphics.push("all")
                love.graphics.setColor(U.pallete_to_love(config.palette.black))
                love.graphics.translate(x, y)

                love.graphics.printf([[
A game by Terracottafrog

Made in 48 hours for the Ludum Dare 52 Compo.

Escape or select for fullscreen.

Enjoy!
]], 8, 6, 80, "left")

            love.graphics.pop()
        end

    love.graphics.pop()
end

return page
