local level_loader = {}

local ldtk = require "libraries.ldtk"

function level_loader.load(path, index)__(path, "string")__(index,"number")
    local layers = {}
    local entities = {}

    function ldtk.layer(lay)
        table.insert(layers, lay)
    end

    function ldtk.entity(entity)
        table.insert(entities, entity)
    end

    ldtk:load(path, index)

    return {
        layers = layers,
        entities = entities,
    }
end

return level_loader
