-- This is a hot reloaded list of constants.
-- Anything that refers to this will get fresh values whenever this changes.
return {
    screen = {
        width = 264,
        height = 164,
        scale = 2,
    },
    palette = {
        tan = { 244, 204, 161 },
        dark_tan = {191, 121, 88},
        sky = { 138, 235, 241},
        red = { 230, 72, 46},
        yellow = { 244, 180, 27 },
        orange = { 244, 126, 27 },
        purple = { 142, 71, 140 },
        lime = { 182, 213, 60 },
        green = { 57, 123, 68 },
        black = { 48, 44, 46 },
        gray = { 160, 147, 142 },
        violet = { 130, 112, 148 },
        pink = { 255, 174, 182 },
    },
    animation = {
        slide_time = 0.3,
        pick_time = 0.25,
        reject_time = 0.25,
        sway_rate = 1,
        sway_amount = 0.025,
        new_sway_rate = 0.5,
        new_sway_amount = 0.025,
        turn_start_time = 0.07,
        turn_end_time = 0.05,
        turn_hang_time = 0.0,
        turn_distance = -100,
        discover = {
            before_slide = 0,
            after_slide = 0.5,
        },
        reject_distance = -75,
    },
    layout = {
        progress_x = 5,
        progress_y = 155,
        progress_width = 140,
        progress_height = 5,
        book_x = 155,
        book_y = 8,
        card_seperation = 65,
        card_offset = -2,
        card_offset_y = 14,
        card = {
            mushroom = {
                offset_x = 71,
                offset_y = 53,
                scale = 0.5,
            }
        }
    },
    gameplay ={
        starting_mushrooms = 10,
        max_mushrooms = 100,
        starting_life = 100,
        life_per_second = 4,
        life_gain_correct = 6,
        life_loss_poison = 33,
        life_loss_safe = 33,
        poison_chance = 0.4,
        message_length = 2,
        poison_bag = {false, false, true, true}
    }
}
