local terebi = require "libraries.terebi"

function love.load()
    terebi.initializeLoveDefaults()

    Screen = terebi.newScreen(640, 490, 1)
        :setBackgroundColor(0, 0, 0)
end

function love.update(dt)

end

function TerebiDraw()
    -- Put drawing code here.
end

function love.draw()
    Screen:draw(TerebiDraw)
end
