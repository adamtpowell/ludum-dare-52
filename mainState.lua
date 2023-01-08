local bump = require "libraries.bump"
local lifebar = require "lifebar"
local page = require "page"
local nata = require "libraries.nata"
local simpleTiledImplementation = require "libraries.sti"

local progressbar = require "progressbar"

local debugInfo = require "entities.debugInfo"

local level_loader = require "libraries.level_loader"

local mushroom = require "mushroom"

local config = require "config"

local species = require "species"

local input = require "controller"

local tablex = require "libraries.batteries.tablex"
local stringx = require "libraries.batteries.stringx"

local timer = require "libraries.timer"

local card = require "card"

local function has_name(species, name)
    for i, spec in ipairs(species) do
        if spec.name == name then
            return true
        end
    end
    return false
end

-- To change states, return a string with the state name.
return {
    showMessage = function(state, message)
        state.message = message
        timer.script(function(wait)
            wait(config.gameplay.message_length)
            if state.message == message then
                state.message = nil
            end
        end)
    end,
    pick_mushroom = function(state, callback)
        timer.tween(config.animation.pick_time, state.mushroom_y, {-10}, "out-cubic", callback)
    end,
    reject_mushroom = function(state, callback)
        timer.tween(config.animation.reject_time, state.mushroom_x, {config.animation.reject_distance}, "linear", callback)
    end,
    new_mushroom = function(state)

        state.mushroom = {}
        state.mushroom.species = state.species[math.random(#state.species)]
        state.mushroom.mushroom = state.mushroom.species:get_mushroom(0,0)
    end,
    new_species = function(state)

        if #state.poisonbag == 0 then
            state.poisonbag = tablex.shallow_copy(config.gameplay.poison_bag)
        end
        local poison = tablex.take_random(state.poisonbag)
        local new_species = species.random(poison)

        local its = 0
        while its < 100 and has_name(state.species, new_species.name) do
            new_species:setName(new_species.options, new_species.poison)
            its = its + 1 -- Limit iteration
        end

        table.insert(state.species, new_species)

        return new_species
    end,
    get_accuracy_percent = function(state)
        print(state.accurate)
        return math.ceil((state.accurate / state.mushrooms_in_level) * 100)
    end,
    choose_mushroom = function(state, accepted)
        state.controls = false
        if not state.mushroom then return end
        local poison = state.mushroom.species.poison
        if accepted and poison then
            timer.script(function(wait)
                love.audio.play(Assets.sound.pick)
                wait(0.35)
                love.audio.play(Assets.sound.gross)
            end)
            state:showMessage("*Dying Noises*")
            state.people_poisoned = state.people_poisoned + 1
            state.progressbar:changeLife(-config.gameplay.life_loss_poison)
            state:pick_mushroom(function()
                state:move_to_next_mushroom()
            end)
        end

        if not accepted and poison then
            love.audio.play(Assets.sound.mushroom_move)
            state.progressbar:changeLife(config.gameplay.life_gain_correct)
            state:reject_mushroom(function()
                state:move_to_next_mushroom()
            end)
            state.accurate = state.accurate + 1
        end

        if accepted and not poison then
            timer.script(function(wait)
                love.audio.play(Assets.sound.pick)
                wait(0.35)
                love.audio.play(Assets.sound.licklips)
            end)
            state.mushrooms_gathered = state.mushrooms_gathered + 1
            state.progressbar:changeLife(config.gameplay.life_gain_correct)
            state:pick_mushroom(function()
                state:move_to_next_mushroom()
            end)
            state.accurate = state.accurate + 1
        end

        if not accepted and not poison then
            love.audio.play(Assets.sound.mushroom_move)
            state:showMessage("I could've made a soup out of that!")
            state.progressbar:changeLife(-config.gameplay.life_loss_safe)
            state:reject_mushroom(function()
                state:move_to_next_mushroom()
            end)
        end

    end,
    end_level = function(state)
        state.mushroom = nil

        state.progressbar:reset()

        state.level_complete = true

        state.next_level_ready = true

        timer.script(function (wait)
            local new_species = state:new_species()

            state.mushroom = {}
            state.mushroom.species = new_species
            state.mushroom.mushroom = state.mushroom.species:get_mushroom(0,0)

            state.mushroom_y = { 140 }
            state.mushroom_x = { config.screen.width + 50 }

            state.mushrooms_left = 1
            wait(config.animation.discover.before_slide)
            timer.tween(config.animation.slide_time, state.mushroom_x, {75}, "linear")
            wait(config.animation.slide_time)
            table.insert(state.specimens, new_species:get_mushroom(0, 0))
            state.goal_page = math.ceil(#state.specimens / 2)
            state.discovery = true
            wait(config.animation.discover.after_slide)


        end)
    end,
    move_to_next_mushroom = function(state)
        timer.script(function (wait)
            state.mushroom_y = { 140 }
            state.mushroom_x = { config.screen.width + 50 }

            state.mushrooms_left = state.mushrooms_left - 1

            if state.mushrooms_left == 0 then
                state:end_level()
            else
                state:new_mushroom()
                timer.tween(config.animation.slide_time, state.mushroom_x, {75}, "linear")
                wait(config.animation.slide_time)

                state.controls = true
            end
        end)
    end,
    next_level = function(state)
        state.discovery = false

        state.message = nil

        state.next_level_ready = false
        state.level_complete = false
        state.mushrooms_in_level = state.mushrooms_in_level + 1
        if state.mushrooms_in_level > config.gameplay.max_mushrooms then
            state.mushrooms_in_level = config.gameplay.max_mushrooms
        end

        state.mushrooms_left = state.mushrooms_in_level + 1
        state.accurate = 0

        state.progressbar:reset(state.mushrooms_in_level)

        state.goal_page = nil

        timer.script(function (wait)
            timer.tween(config.animation.reject_time, state.mushroom_x, {config.animation.reject_distance}, "linear")

            wait(config.animation.reject_time)

            state:move_to_next_mushroom()
        end)

    end,
    enter = function(state)
        love.audio.play(Assets.ld52music)
        state.discovery = false
        state.pool = nata.new()
        state.species = {}

        table.insert(state.species, species.random(true))
        table.insert(state.species, species.random(false))

        local its = 0
        while its < 100 and state.species[1].name == state.species[2].name do
            print("name loop before", state.species[1].name, state.species[2].name)
            state.species[1]:setName(state.species[1].options, state.species[1].poison)
            print("name loop after", state.species[1].name, state.species[2].name)
            its = its + 1
        end

        state.species[1].options.cap_color = (state.species[2].options.cap_color + 0.5) % 1.0
        state.species[1].options.cap_pattern = (state.species[2].options.cap_pattern + 0.5) % 1.0

        state.specimens = {}
        for _, species in ipairs(state.species) do
            table.insert(state.specimens, species:get_mushroom(0, 0))
        end

        state.page = 1
        state.controls = true

        state.mushrooms_in_level = config.gameplay.starting_mushrooms
        state.mushrooms_left = state.mushrooms_in_level
        state.accurate = 0

        state.mushroom_y = { 140 }
        state.mushroom_x = { 75 }

        state.next_level_ready = false

        state.time = 0

        state.progressbar = lifebar.new(config.layout.progress_x, config.layout.progress_y, config.layout.progress_width, config.layout.progress_height)

        state.last_page_in_front = false
        state.last_page_pos = { config.layout.book_x, config.layout.book_y }
        state.last_page = state.page

        state.can_flip = true

        state.cloudx = 0

        state.logx = {0}

        state.poisonbag = tablex.shallow_copy(config.gameplay.poison_bag)

        state.level_complete = true

        state.instructions = false
        state.title = true
        state.gameover = false

        state.mushrooms_gathered = 0

        state.people_poisoned = 0

        local title_species = species.random(false)
        title_species.options.stalk_height = 0.5

        state.title_mushroom = title_species:get_mushroom(0,0)
    end,
    startFirstLevel = function(state)
        state.instructions = false
        state:showMessage("I can't wait to learn from an expert like you!")
        state.level_complete= false
        -- state:new_mushroom()
        state:next_level()
    end,
    turnPageRight = function(state)
        state.last_page = state.page

        state.page = state.page + 1

        if state.page > math.ceil(#state.specimens / 2) then
            state.page = 1
        end

        if state.page ~= state.last_page then
            love.audio.play(Assets.sound.flip:clone())
            state.can_flip = false
            state.last_page_in_front = true

            timer.script(function(wait)
                timer.tween(config.animation.turn_start_time, state.last_page_pos, { config.layout.book_x - config.animation.turn_distance, config.layout.book_y}, "out-cubic")

                wait(config.animation.turn_start_time + config.animation.turn_hang_time)
                state.last_page_in_front = false

                timer.tween(config.animation.turn_end_time, state.last_page_pos, { config.layout.book_x, config.layout.book_y},
                "out-cubic")

                wait(config.animation.turn_end_time)

                state.can_flip = true
            end)
        end


    end,
    turnPageLeft = function(state)
        state.last_page = state.page

        state.page = state.page - 1

        if state.page < 1 then
            state.page = math.ceil(#state.specimens / 2)
        end

        if state.page ~= state.last_page then
            love.audio.play(Assets.sound.flip:clone())
            state.can_flip = false
            state.last_page_in_front = true

            timer.script(function(wait)
                timer.tween(config.animation.turn_start_time, state.last_page_pos, { config.layout.book_x - config.animation.turn_distance, config.layout.book_y}, "out-cubic")

                wait(config.animation.turn_start_time + config.animation.turn_hang_time)

                state.last_page_in_front = false

                timer.tween(config.animation.turn_end_time, state.last_page_pos, { config.layout.book_x, config.layout.book_y}, "out-cubic")

                wait(config.animation.turn_end_time)

                state.can_flip = true
            end)
        end


    end,
    update = function(state, dt)
        if state.progressbar:getLife() < 0 then
            if not state.gameover then
                love.audio.play(Assets.sound.gong)
                love.audio.stop(Assets.ld52music)
            end
            state.gameover = true
            state.controls = false
            state.level_complete = true
        end

        if state.gameover then
            state.progressbar.life = 0
        end

        local last_mushroom_x = state.mushroom_x[1]
        timer.update(dt)
        local current_mushroom_x = state.mushroom_x[1]

        if math.abs(last_mushroom_x - current_mushroom_x) < 30 then
            state.logx[1] = state.logx[1] + (current_mushroom_x - last_mushroom_x)
        end

        state.time = state.time + dt
        if not state.gameover and state.controls then
            if state.mushrooms_left > 0 then
                if input:pressed("accept") then
                    state:choose_mushroom(true)
                elseif input:pressed("reject") then
                    state:choose_mushroom(false)
                end
            else
            end
        end

        if not state.level_complete then
            state.progressbar:changeLife(-config.gameplay.life_per_second * dt)
        end

        if input:pressed("start") and state.next_level_ready then
            state:next_level()
        end

        if state.gameover and input:pressed("start") then
            love.audio.play(Assets.sound.start)
            return "main"
        end

        if state.instructions and input:pressed("start") then
            love.audio.play(Assets.sound.start)
            print("Starting first level")
            state:startFirstLevel()
        end

        if state.title and input:pressed("start") then
            love.audio.play(Assets.sound.start)
            state.title = false
            state.instructions = true
        end

        if state.instructions and input:pressed('accept') then
            return "main" -- DEBUG: Restart
        end

        if state.goal_page and state.page ~= state.goal_page then
            if state.can_flip then
                state:turnPageRight()
            end
        end

        if state.goal_page and state.page ==state.goal_page then
            timer.script(function(wait)
                wait(0.4)
                love.audio.play(Assets.sound.ding)
            end)
            state.goal_page = nil
        end


        if input:pressed("right") and state.can_flip then
            state:turnPageRight()
        end

        if input:pressed("left") and state.can_flip then
            state:turnPageLeft()
        end

        -- Update the entities in the pool.
        state.pool:flush()
        state.pool:emit("update", dt)

        state.cloudx = state.cloudx + 2 * dt
    end,
    draw = function(state)
        love.graphics.setFont(MainFont)
        love.graphics.push("all")
            love.graphics.setColor(U.pallete_to_love(config.palette.sky))
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.pop()

        local cloud1quad = love.graphics.newQuad(state.cloudx * 3, 0, Assets.clouds1:getWidth(), Assets.clouds1:getHeight(), Assets.clouds1:getWidth(), Assets.clouds1:getHeight())
        local cloud2quad = love.graphics.newQuad(state.cloudx, 0, Assets.clouds1:getWidth(), Assets.clouds1:getHeight(), Assets.clouds1:getWidth(), Assets.clouds1:getHeight())

        love.graphics.draw(Assets.clouds1, cloud1quad, 0, 0)
        love.graphics.draw(Assets.clouds2, cloud2quad, 0, 0)

        local log_quad = love.graphics.newQuad(-state.logx[1], 0, love.graphics:getWidth(), Assets.log:getHeight(), Assets.log:getWidth(), Assets.log:getHeight())
        love.graphics.draw(Assets.log, log_quad, 0, 126)

        love.graphics.push("all")
            love.graphics.translate(state.mushroom_x[1], state.mushroom_y[1])
            love.graphics.rotate(math.sin(state.time / config.animation.sway_rate) * config.animation.sway_amount)
            love.graphics.translate(-state.mushroom_x[1], -state.mushroom_y[1])
            if state.mushroom and not state.title then state.mushroom.mushroom:draw(state.mushroom_x[1], state.mushroom_y[1]) end
        love.graphics.pop()

        love.graphics.push("all")
            local x= 80
            local y = 140
            love.graphics.translate(x, y)
            love.graphics.rotate(math.sin(state.time / config.animation.sway_rate) * config.animation.sway_amount)
            love.graphics.translate(-x, -y)
            if state.title then state.title_mushroom:draw(x, y) end
        love.graphics.pop()

        local num_pages = math.ceil(#state.specimens / 2)
        -- if num_pages > 3 then num_pages = 3 end

        -- for i = num_pages, 1, -1 do
        --     love.graphics.draw(Assets.book, config.layout.book_x + (i - 1) * 2, config.layout.book_y + (i - 1) * 2)
        -- end

        local new_sway_state = math.sin(state.time / config.animation.new_sway_rate) * config.animation.new_sway_amount
        if not state.discovery then
---@diagnostic disable-next-line: cast-local-type
            new_sway_state = nil
        end
        if state.last_page_in_front then
            page.draw_page(
                config.layout.book_x,
                config.layout.book_y,
                state.page,
                num_pages,
                state.specimens,
                new_sway_state,
                state.title
            )
            page.draw_page(
                state.last_page_pos[1],
                state.last_page_pos[2],
                state.last_page,
                num_pages,
                state.specimens,
                new_sway_state,
                state.title
            )
        else
            page.draw_page(
                state.last_page_pos[1],
                state.last_page_pos[2],
                state.last_page,
                num_pages,
                state.specimens,
                new_sway_state,
                state.title
            )
            page.draw_page(
                config.layout.book_x,
                config.layout.book_y,
                state.page,
                num_pages,
                state.specimens,
                new_sway_state,
                state.title
            )
        end

        if state.discovery then
            state.message = "Wow! I haven't seen this before!"
            love.graphics.draw(Assets.enter_box, 3, 150)
            love.graphics.push("all")
                love.graphics.setColor(U.pallete_to_love(config.palette.black))
                love.graphics.print("Enter / Start to continue", 8, 149)
            love.graphics.pop()
        end

        if state.message then
            love.graphics.draw(Assets.speech, 3, 2)
            love.graphics.push("all")
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.setFont(MainFont)
                love.graphics.printf(state.message, 8, 8, 150, "left")
            love.graphics.pop()
        end

        if not state.title and not state.instructions and not state.gameover and not state.discovery then
            state.progressbar:draw()
        end
        if state.instructions then
            love.graphics.draw(Assets.tall_speech, 3, 2)
            love.graphics.draw(Assets.enter_box, 3, 150)
            love.graphics.push("all")
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.setFont(MainFont)
                love.graphics.printf([[
Identify the deadly mushrooms using your memory and guidebook.

Z/A to eat the mushroom. X/B to reject it. If you make a mistake, you lose time.

Arrow keys/DPad to flip through the book, once you discover more species.
]], 8, 8, 130, "left")

                love.graphics.print("Enter to continue", 8, 149)

            love.graphics.pop()
        end

        if state.gameover then
            love.graphics.draw(Assets.tall_speech, 3, 2)
            love.graphics.draw(Assets.enter_box, 3, 150)
            love.graphics.push("all")
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.setFont(MainFont)
                love.graphics.printf(stringx.apply_template([[
Looks like your foraging days are over!

You gathered $mushrooms_gathered good mushrooms, discovered $species_discovered species, and poisoned $people_poisoned people.

You got $score points!

Game over.
]], {
    mushrooms_gathered = state.mushrooms_gathered,
    species_discovered = #state.specimens,
    people_poisoned = state.people_poisoned,
    score = state.mushrooms_gathered + #state.specimens * 8 - state.people_poisoned * 2,

}), 8, 8, 130, "left")
                love.graphics.print("Enter / Start to continue", 8, 149)
            love.graphics.pop()

        end


        if state.title then
            love.graphics.draw(Assets.title, 33, 9)
            love.graphics.draw(Assets.enter_box, 3, 150)
            love.graphics.push("all")
            love.graphics.setColor(U.pallete_to_love(config.palette.black))
            love.graphics.print("Enter / Start to continue", 8, 149)
            love.graphics.pop()
        end


        state.pool:emit("draw")
    end,
    exit = function(state)

    end,
}
