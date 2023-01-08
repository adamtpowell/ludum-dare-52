local mushroom = require "mushroom"
local config = require "config"

local species = {}
species.__index = species

local tablex = require "libraries.batteries.tablex"

-- AXES

--[[

-- Seperating
X Cap color - an array of colors, index by rounding from the scalar
Stalk sameness - 0 to 0.5, if over 0.5 then the stalk is the same color as the cap
Cap shape - index to an array of possible general cap shapes
X Cap pattern - an array of patterns
X Cap width - moves the min and max based on how high
X Cap height - moves the min and max based on how high
X stalk width - moves the min and max based on how hight
X stalk height - see above

-- Non-seperating
Stalk color - see above
Cap shape style - varies the shape within the cap shape.
X Cap density - how dense the pattern is
X Stalk wobbliness - moves the percent based on how high
X stalk width variation - moves the variation based on how high
Xcap angle - moves the min and max based on how high
]]

local function float_index(array, float)
    local index = math.floor(float * #array) + 1
    return array[index]
end

local cap_colors = {config.palette.black, config.palette.violet, config.palette.red, config.palette.yellow, config.palette.lime}
local cap_color_names = {"black", "violet", "red","yellow","lime"}

local fill_types = { "spot", "speckle", "stripes", "circled" }
local fill_type_names = { "spotted", "speckled", "striped", "ringed" }

local function get_possible_first(options, poison)
    local pos = {"spore", "forest", "swamp", "pond", "common", "rare", "meadow"}

    for i = 0, 2 do
        table.insert(pos, float_index(cap_color_names, options.cap_color))
    end

    for i = 0, 2 do
        table.insert(pos, float_index(fill_type_names, options.cap_pattern))
    end

    if poison then
        table.insert(pos, "deadly")
        table.insert(pos, "sleepy")
        table.insert(pos, "poison")
        table.insert(pos, "bitter")
    end

    if not poison then
        table.insert(pos, "tasty")
        table.insert(pos, "tasty")
        table.insert(pos, "tasty")
    end

    if options.stalk_wobbliness < 0.2 then
        table.insert(pos, "sturdy")
        table.insert(pos, "sturdy")
        table.insert(pos, "delicious")
        table.insert(pos, "delicious")
    end

    if options.stalk_height > 0.8 and options.stalk_width < 0.5 then
        table.insert(pos, "pointy")
        table.insert(pos, "pointy")
    end

    if options.stalk_width > 0.8 and options.stalk_height < 0.5 then
        table.insert(pos, "wide")
        table.insert(pos, "broad")
        table.insert(pos, "wide")
        table.insert(pos, "broad")
    end

    if options.stalk_width > 0.8 and options.stalk_height > 0.8 then
        table.insert(pos, "giant")
        table.insert(pos, "giant")
        table.insert(pos, "giant")
        table.insert(pos, "huge")
        table.insert(pos, "huge")
        table.insert(pos, "huge")
    end

    if options.cap_density > 0.8 then
        table.insert(pos, "painted")
        table.insert(pos, "painted")
        table.insert(pos, "painted")
        table.insert(pos, "painted")
        table.insert(pos, "painted")
    end

    if options.stalk_height < 0.3 then
        -- table.insert(pos, "stout")
        -- table.insert(pos, "short")
        table.insert(pos, "little")
        table.insert(pos, "painted")
        table.insert(pos, "painted")
        table.insert(pos, "painted")
    end

    if options.stalk_height > 0.8 then
        table.insert(pos, "giant")
        table.insert(pos, "giant")
        -- table.insert(pos, "towering")
    end



    return pos
end

local function get_possible_last(options, poison)
    local pos = {"cap", "bell"}
    if options.stalk_height < 0.3 then
        table.insert(pos, "tack")
        table.insert(pos, "tack")
        table.insert(pos, "tack")
        table.insert(pos, "stub")
        table.insert(pos, "stub")
        table.insert(pos, "stub")
    end

    if options.stalk_height > 0.8 then
        table.insert(pos, "tower")
        table.insert(pos, "tower")
        table.insert(pos, "tower")
        table.insert(pos, "tower")
    end

    if options.stalk_height > 0.8 and options.stalk_width < 0.5 then
        table.insert(pos, "spire")
        table.insert(pos, "spire")
        table.insert(pos, "spire")
        table.insert(pos, "spire")
        table.insert(pos, "spire")
    end

    if options.cap_angle > 0.8 then
        table.insert(pos, "angler")
        table.insert(pos, "angler")
        table.insert(pos, "angler")
        table.insert(pos, "angler")
    end

    if poison then
        table.insert(pos, "ender")
        table.insert(pos, "killer")
    else
        table.insert(pos, "morsel")
        table.insert(pos, "snack")
        table.insert(pos, "lunch")
    end

    return pos
end

function species:setName(options, poison)
    local firsts = get_possible_first(options, poison)
    local lasts = get_possible_last(options, poison)
    local firsti = love.math.random(1, #firsts)
    local first = firsts[firsti]
    local secondi = love.math.random(1, #lasts)
    local second = lasts[secondi]

    self.name = first .. " " .. second
end

function species.new(options, poison)
    local self = setmetatable({}, species)

    self.options = options
    self.poison = poison

    self:setName(options, poison)

    return self
end


function species.random(poison)
    return species.new({
            cap_color = math.random(),
            stalk_width = math.random(),
            stalk_height = math.random(),
            cap_width = math.random(),
            cap_height = math.random(),
            cap_angle = math.random(),
            stalk_wobbliness = math.random(),
            stalk_width_variation = math.random(),
            cap_density = math.random(),
            cap_pattern = math.random(),
            stalk_sameness = math.random(),
            movemultiplier = math.random(),
    }, poison)
end

function species:set_options(options)
    self.options = options
    print(self.options.cap_color)
end


function species:get_mushroom(x, y)

    local width_base = 6 + 6 * self.options.stalk_width
    local width_variance =  width_base * 0.1

    local height_base = 20 + 65 * self.options.stalk_height
    local height_variance = height_base * 0.1

    local angle_max = 0 + 5.5 * self.options.cap_angle

    local movepercent = 5 + 65 * self.options.stalk_wobbliness
    local growpercent = 0 + 80 * self.options.stalk_width_variation
    if movepercent > 100 then movepercent = 100 end
    if growpercent > 100 then growpercent = 100 end

    local head_width_base = 20 + 40 * self.options.cap_width
    local head_width_variance = 20 / 2
    local head_height_base = 15 + 25 * self.options.cap_height
    local head_height_variance = 10 / 2

    local stalk_color = config.palette.tan
    if self.options.stalk_sameness > 0.5 then
        -- stalk_color = float_index(cap_colors, self.options.cap_color)
    end


    return mushroom.new(x, y, {
        cap_color = float_index(cap_colors, self.options.cap_color),
        stalk_color = stalk_color,
        streak_color = config.palette.dark_tan,
        minwidth = width_base,
        maxwidth = width_base + width_variance,
        minheight = height_base,
        maxheight = height_variance + height_base,
        minangle = -angle_max,
        maxangle = angle_max,
        mintopcurve = 2,
        maxtopcurve = 15,
        center_width = 35,
        fill_type = float_index(fill_types, self.options.cap_pattern),
        fill_amount = self.options.cap_density,
        headminwidth = head_width_base,
        headmaxwidth = head_width_base + head_width_variance,
        headminheight = head_height_base,
        headmaxheight = head_height_base + head_height_variance,
        movepercent = 100 - movepercent,
        growpercent = 100 - growpercent,
        movemultiplier = self.options.movemultiplier * 0.6
    }, self)
end


return species
