local config = require "config"
local input = require "controller"

local mushroom = {}
mushroom.__index = mushroom

local pixelcode = [[
    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return vec4(0, 0, 0, texcolor[3] > 0.25 ? 1.0 : 0.0);
    }
]]

local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

local mushroom_shader = love.graphics.newShader(pixelcode, vertexcode)

local function get_stalk_parts(background_color, streak_color)
    local stalk_parts = love.graphics.newCanvas(32, 200)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader()
    love.graphics.setCanvas(stalk_parts)
        love.graphics.setColor(U.pallete_to_love(background_color))
        love.graphics.rectangle("fill", 0, 0, 32, 200)

        for y =  0,200, 1 do
            local x = math.floor(love.math.random(0, 16)) * 2

            love.graphics.setColor(U.pallete_to_love(streak_color))

            love.graphics.line(x, y, x, y + love.math.random(4,6))
        end

    love.graphics.setCanvas()

    return stalk_parts
end

local function get_stalk(background_color, streak_color, minwidth, maxwidth, minheight, maxheight, movepercent, growpercent, movemultiplier)
    local stalk_parts = get_stalk_parts(background_color, streak_color)

    local stalk = love.graphics.newCanvas(64, 100)
    love.graphics.setCanvas{stalk}
        local xpos = 0
        local xdir = 0
        local width = math.random(minwidth, maxwidth)
        local height = math.random(minheight, maxheight)
        for y = 0, height do
            if math.random(100) > movepercent then
                xdir = math.random(-1, 1)
            end
            xpos = xpos + xdir * movemultiplier
            if math.random(100) > growpercent then
                width = width + math.random(-1, 1)
                if width < minwidth then width = minwidth end
                if width > maxwidth then width = maxwidth end
            end
            local xoffset = width/ 2

            local quad = love.graphics.newQuad(0, y, width, 1, 32, 200)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(stalk_parts, quad, 32 + xpos - xoffset, 100 - y)
        end
    love.graphics.setCanvas()


    -- local sprite = love.graphics.newCanvas(
    return stalk, xpos, height
end

local function get_head_stencil(width, height, mintopcurve, maxtopcurve, center_width)
    local wpx = function(amt) return (amt / 75) * width end
    local hpx = function(amt) return (amt / 50) * height end
    return function ()
        love.graphics.polygon("fill", {
            -- Bottom
            wpx(4), height - hpx(4),
            width * 0.25, height - hpx(2),
            width / 2, height,
            width * 0.75, height -hpx(2),
            width - wpx(4), height - hpx(4),

            -- Right curve
            width - wpx(10), height / 2,
            width - wpx(25), hpx(math.random(mintopcurve, maxtopcurve)),

            -- Center
            width - wpx(center_width), 0,
            wpx(center_width), 0,

            -- Left curve
            wpx(25), hpx(math.random(mintopcurve, maxtopcurve)),
            wpx(10), height / 2,
        })
    end
end

local function spot_fill(minamount, maxamount, minsize, maxsize)
    return function(width, height)
        for i = 0, math.random(minamount, maxamount) do
            love.graphics.circle('fill', math.random(0, width), math.random(0, height), math.random(minsize, maxsize))
        end
    end
end

local function circle_fill(minamount, maxamount, minsize, maxsize)
    return function(width, height)
        for i = 0, math.random(minamount, maxamount) do
            love.graphics.circle("line", math.random(0, width), math.random(0, height), math.random(minsize, maxsize))
        end
    end
end

local function stripe_fill(minamount, maxamount)
    return function(width, height)
        local stripe_height = Assets.stripes:getHeight()
        local stripe_width = Assets.stripes:getWidth()
        local width = minamount + love.math.random() * (maxamount - minamount)
        local height = minamount + love.math.random() * (maxamount - minamount)
        local stripeQuad = love.graphics.newQuad(
            love.math.random(0, stripe_width),
            love.math.random(0, stripe_height),
            stripe_height,
            stripe_width,
            stripe_width * width,
            stripe_height * height
        )
        love.graphics.draw(Assets.stripes, stripeQuad, 0, 0)
    end
end

local function get_head(minwidth, maxwidth, minheight, maxheight, background_color, minangle, maxangle, mintopcurve, maxtopcurve, center_width, fill_function)
    local width = math.random(minwidth, maxwidth)
    local height = math.random(minheight, maxheight)

    local head = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas{head, stencil=true}
        love.graphics.stencil(get_head_stencil(width, height, mintopcurve, maxtopcurve, center_width), "replace", 1)
        love.graphics.setStencilTest("greater", 0)

        love.graphics.setColor(U.pallete_to_love(background_color))
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1, 1, 1, 1)

        fill_function(width, height)

        love.graphics.setStencilTest()
    love.graphics.setCanvas()

    local angle = math.random(minangle, maxangle) / 10

    return head, angle
end

function mushroom:basic_stalk()
    return get_stalk(self.options.stalk_color, self.options.streak_color, self.options.minwidth, self.options.maxwidth, self.options.minheight, self.options.maxheight, self.options.movepercent, self.options.growpercent, self.options.movemultiplier)
end

function mushroom:basic_head()
    local fill
    if self.options.fill_type == "spot" then
        local minamount = 10 + self.options.fill_amount * 10
        local maxamount = minamount + 10
        fill = spot_fill(minamount, maxamount, 4, 6)
    elseif self.options.fill_type == "circled" then
        local minamount = 10 + self.options.fill_amount * 10
        local maxamount = minamount + 10
        fill = circle_fill(minamount, maxamount, 4, 6)
    elseif self.options.fill_type == "speckle" then
        local minamount = 20 + self.options.fill_amount * 20
        local maxamount = minamount + 20
        fill = spot_fill(minamount, maxamount, 1, 2)
    elseif self.options.fill_type == "glossy" then
        fill = function() end
    elseif self.options.fill_type == "stripes" then
        local minamount = 0.1 + self.options.fill_amount * 2
        local maxamount = minamount + minamount * 0.25
        fill = stripe_fill(minamount, maxamount)
    end
    return get_head(self.options.headminwidth, self.options.headmaxwidth, self.options.headminheight, self.options.headmaxheight, self.options.cap_color, self.options.minangle, self.options.maxangle, self.options.mintopcurve, self.options.maxtopcurve, self.options.center_width, fill)
end

function mushroom.new(x, y, options, species)
    local self = setmetatable({}, mushroom)
    self.options = options
    self.species = species

    self.stalk, self.capx, self.capy = self:basic_stalk()
    self.head, self.head_angle = self:basic_head()
    self.x = x
    self.y = y

    return self
end

function mushroom:update()
    if input:down("action") then
        self.stalk, self.capx, self.capy = self:basic_stalk()
        self.head, self.head_angle = self:basic_head()
    end
end

local function draw_stalk(stalk, head, capx, capy, head_angle)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(stalk, 0, 0)
end

local function draw_head(stalk, head, capx, capy, head_angle)
    love.graphics.setColor(1, 1, 1, 1)

    local headx = stalk:getWidth() / 2 + capx
    local heady = stalk:getHeight() - capy
    love.graphics.draw(head, headx, heady, head_angle, 1, 1, head:getWidth() / 2, head:getHeight() / 2)
end

function mushroom:draw(x, y)
    love.graphics.push("transform")

    love.graphics.translate(-self.stalk:getWidth() / 2 + x, - self.stalk:getHeight() + y)

    local function draw_shadow(drawfun, x, y)
        love.graphics.setColor(0, 0, 0, 0)
        love.graphics.translate(x, y)
        love.graphics.setShader(mushroom_shader)
        drawfun(self.stalk, self.head, self.capx, self.capy, self.head_angle)

        love.graphics.translate(-x,-y)
        love.graphics.setShader()
    end

    draw_shadow(draw_stalk, 1, 1)
    draw_shadow(draw_stalk, 1, 0)
    draw_stalk(self.stalk, self.head, self.capx, self.capy, self.head_angle)

    draw_shadow(draw_head, 1, 1)
    draw_shadow(draw_head, 1, 0)
    draw_head(self.stalk, self.head, self.capx, self.capy, self.head_angle)

    love.graphics.pop()
    love.graphics.push("all")
        love.graphics.translate(x, y)
        local scale = self.options.minwidth / (Assets.root:getWidth() * 0.7)
        love.graphics.draw(Assets.root,0,0,0, scale, 1, Assets.root:getWidth() / 2, Assets.root:getHeight() / 2)
    love.graphics.pop()
end

return mushroom
