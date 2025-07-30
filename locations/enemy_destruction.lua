-- Never check these entities. They will be subject to the "seen" method of defeating
local excludedEntities = {
    -- Larry Jr.
    {type = 19, variant = 0},

    -- The Hollow
    {type = 19, variant = 1},

    -- Tuff Twin
    {type = 19, variant = 2},

    -- The Shell
    {type = 19, variant = 3},

    -- Brownie
    {type = 402, variant = 0},

    -- Gurgling
    {type = 237, variant = 1},

    -- Turdling
    {type = 237, variant = 2},

    -- The Frail
    {type = 64, variant = 2},

    -- Gemini (Main)
    {type = 79, variant = 0},

    -- Steven (Main)
    {type = 79, variant = 1},

    -- Big & Medium Fistula
    {type = 71, variant = 0},
    {type = 71, variant = 1},
    {type = 72, variant = 0},
    {type = 72, variant = 1},

    -- Big & Medium Blastocyst
    {type = 71, variant = 0},
    {type = 72, variant = 0},

    -- Envy
    {type = 51, variant = 0},
    {type = 51, variant = 10},
    {type = 51, variant = 20},

    -- Super Envy
    {type = 51, variant = 1},
    {type = 51, variant = 11},
    {type = 51, variant = 21},

    -- The Fallen
    {type = 81, variant = 0},

    -- The Matriarch
    {type = 413, variant = 0}
}

-- Tries to grant a location check for defeating this entity.
local function tryGrantLocationForTypeVariant(type, variant)
    local nameKey = tostring(type) .. ":" .. tostring(variant)
    local name = AP_MAIN_MOD.ENTITIES_DATA[nameKey]

    -- No name found, I guess.
    if name == nil then
        return
    end

    local locationName = name .. " Defeated"
    local locationID = AP_MAIN_MOD.LOCATIONS_DATA[locationName]

    if locationID ~= nil then
        AP_MAIN_MOD:sendLocation(locationID)
    end
end

-- Enemies we've seen this room
local seen = {}

-- Handles locations for defeated enemies
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    local type = entity.Type
    local variant = entity.Variant

    -- Mark enemies that we've "seen" (read: killed) in this room.
    -- When the room is completed, checks for multipart enemies will be granted and this will be flushed
    seen[#seen] = {type = type, variant = variant}

    for _, v in ipairs(excludedEntities) do
        if v.type == type and v.variant == variant then
            return -- Not checking this entity
        end
    end

    tryGrantLocationForTypeVariant(type, variant)
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function ()
    for _, v in ipairs(seen) do
        tryGrantLocationForTypeVariant(seen.type, seen.variant) -- Grant locations
    end

    seen = {} -- Flush the seen table
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    seen = {} -- Flush seen table, in case the player escapes a fight and doesn't actually win
end)