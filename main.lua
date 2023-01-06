-- Documentation is at https://github.com/oniietzschan/terebi
local terebi = require "libraries.terebi"

-- Documentation is at https://tesselode.github.io/nata/topics/tutorial.md.html
local nata = require "libraries.nata"

-- Documentation is at https://github.com/tesselode/baton
local baton = require "libraries.baton"

-- Documentation is at https://github.com/kikito/bump.lua
local bump = require "libraries.bump"

-- Documentation is at https://github.com/karai17/Simple-Tiled-Implementation
local simpleTiledImplementation = require "libraries.sti"

local assets = require "libraries.cargo".init("assets")

local config = require "config"

lume = require "libraries.lume"

-- The global baton instance. Only supports a single controller.
Input = baton.new {
  controls = {
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
    action = {'key:x', 'button:a'},
  },
  pairs = {
    move = {'left', 'right', 'up', 'down'}
  },
  joystick = love.joystick.getJoysticks()[1],
}

World = bump.newWorld()

function love.load()
    terebi.initializeLoveDefaults()


    -- Object which stores the logical screen, drawn to the real screen in love.draw().
    Screen = terebi.newScreen(640, 490, 1)
        :setBackgroundColor(0, 0, 0)

    -- The main nata pool.
    Pool = nata.new{}

    -- Map = simpleTiledImplementation("assets/levels/Frogs.lua")
end

function love.update(dt)
    require("libraries.lurker").update()

    -- Update the entities in the pool.
    Pool:flush()
    Pool:emit("update", dt)

    -- Update controls
    Input:update()
end

-- Draw to the virtual Terebi screen. Everything to be scaled should go here.
function TerebiDraw()
    Pool:emit("draw")
end

---@diagnostic disable-next-line: duplicate-set-field -- This is to fix a bug cause by lurker's design.
function love.draw()
    Screen:draw(TerebiDraw)
end
