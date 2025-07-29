local util = require("util")

local gridEntityTypeToName = {
    [GridEntityType.GRID_ROCK_SS] = "Super Special Rocks",
    [GridEntityType.GRID_ROCK_GOLD] = "Fool's Gold",
    [GridEntityType.GRID_ROCK_ALT2] = "A Mysterious Door"
}

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function (_, type, variant, subType, gridIndex, seed)
    if type < 1000 then -- Grid entities only!
        return
    end

    local name = gridEntityTypeToName[type]

    if name == nil then -- Not an ap item, so we don't care
        return
    end

    if AP_MAIN_MOD:checkUnlockedByName(name) then -- Item is unlocked so w/e
        return
    end

    -- Anything locked is replaced with rocks
    return {GridEntityType.GRID_ROCK, variant, subType, gridIndex}
end)