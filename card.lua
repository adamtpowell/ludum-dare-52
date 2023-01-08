local config = require "config"
local card = {}

function card.draw(x, y, mushroom, rotation, is_new)
    love.graphics.push()

        love.graphics.translate(x + 50, y + 30)
        love.graphics.rotate(rotation or 0)
        love.graphics.translate(-x - 50, -y -30)
        love.graphics.draw(Assets.card, x, y)

        if is_new then
            love.graphics.draw(Assets.new, x + 3, y)
        end

        love.graphics.push("all")
            love.graphics.translate(x + config.layout.card.mushroom.offset_x,  y + config.layout.card.mushroom.offset_y)
            love.graphics.push("all")
                love.graphics.scale(config.layout.card.mushroom.scale, config.layout.card.mushroom.scale)
                mushroom:draw(0, 0)
            love.graphics.pop()
        love.graphics.pop()

        love.graphics.push("all")
        love.graphics.translate(x, y)
            if mushroom.species.poison then
                love.graphics.draw(Assets.skull, 11, 39)
            end
            love.graphics.setColor(U.pallete_to_love(config.palette.black))
            love.graphics.printf(mushroom.species.name, 10, 3, 45)
        love.graphics.pop()

        love.graphics.push("all")

        love.graphics.pop()

    love.graphics.pop()
end

return card
