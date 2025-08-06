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

-- Handles "seeing" enemies (that we have defeated!)
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    local type = entity.Type
    local variant = entity.Variant

    -- Mark enemies that we've "seen" (read: killed) in this room.
    -- When the room is completed, checks will be granted and this will be flushed
    seen[#seen + 1] = {type = type, variant = variant}
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