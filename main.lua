if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

require "libraries.typing"
Assets = require "libraries.cargo".init("assets")
lume = require "libraries.lume"

local terebi = require "libraries.terebi"

local mainState = require "mainState"

local machine = require "globalMachine"

local config = require "config"

local input = require "controller"

U = require "u"


function love.load()

    love.math.setRandomSeed(love.timer.getTime())
    math.randomseed(love.timer.getTime())
    terebi.initializeLoveDefaults()

    MainFont = love.graphics.newFont("assets/fonts/Silkscreen-Regular.ttf", 8, "none")
    DisplayFont = love.graphics.newFont("assets/fonts/rainyhearts.ttf", 16, "none")

    Assets.clouds1:setWrap("repeat", "repeat")
    Assets.clouds2:setWrap("repeat", "repeat")

    Assets.log:setWrap("repeat", "clampzero")

    -- Object which stores the logical screen, drawn to the real screen in love.draw().
    Screen = terebi.newScreen(config.screen.width, config.screen.height, config.screen.scale)
        :setBackgroundColor(0, 0, 0)

    Assets.ld52music:setLooping(true)

    love.audio.play(Assets.ld52music)

    Assets.stripes:setWrap("repeat", "repeat")
end

function love.update(dt)
    require("libraries.lurker").update()

    Screen:setDimensions(config.screen.width, config.screen.height, config.screen.scale)

    input:update()

    machine:update(dt)
end

-- Draw to the virtual Terebi screen. Everything to be scaled should go here.
function TerebiDraw()
    machine:draw()
end

---@diagnostic disable-next-line: duplicate-set-field -- This is to fix a bug cause by lurker's design.
function love.draw()
    Screen:draw(TerebiDraw)
end
