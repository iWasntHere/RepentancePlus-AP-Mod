local util = Archipelago.util

local bossLocationNames = {
    [EntityType.ENTITY_MOM] = "Mom",
    [EntityType.ENTITY_MOMS_HEART] = "Mom's Heart",
    [EntityType.ENTITY_HUSH] = "Hush",
    [EntityType.ENTITY_DELIRIUM] = "Delirium",
    [EntityType.ENTITY_BEAST] = "The Beast",
    [EntityType.ENTITY_MOTHER] = "Mother",
    [EntityType.ENTITY_ULTRA_GREED] = "Ultra Greed",
    [EntityType.ENTITY_ISAAC] = "Isaac",
    [EntityType.ENTITY_SATAN] = "Satan",
    [EntityType.ENTITY_THE_LAMB] = "The Lamb",
    [EntityType.ENTITY_MEGA_SATAN_2] = "Mega Satan",
    [EntityType.ENTITY_MOMS_HEART] = "Mom's Heart"
}

-- Since tainted charcters have 'grouped' requirements for marks, these ones can act alone
local singleTaintedLocations = {
    ["Ultra Greedier"] = true,
    ["The Beast"] = true,
    ["Mother"] = true,
    ["Delirium"] = true,
    ["Mega Satan"] = true
}

local main4Bosses = {"Isaac", "???", "Satan", "The Lamb"}
--- Returns true if the character has completed the "main 4" bosses.
--- @param characterMarks table
local function hasMain4BossMarks(characterMarks)
    for _, v in ipairs(main4Bosses) do
        if characterMarks[v] == nil then
            return false
        end
    end

    return true
end

--- Returns true if the character has completed boss rush and hush
--- @param characterMarks table
local function hasBossRushAndHush(characterMarks)
    return characterMarks["Hush"] ~= nil and characterMarks["Boss Rush"] ~= nil
end

local allMarks = {
    "Isaac", "???", "Satan", "The Lamb", "Boss Rush",
    "Hush", "Delirium", "Mother", "The Beast", "Ultra Greed",
    "Ultra Greedier", "Mega Satan", "Mom's Heart"
}
--- Returns true if the character has completed all marks.
--- @param characterMarks table
--- @return boolean
local function hasAllMarks(characterMarks)
    for _, v in ipairs(allMarks) do
        if characterMarks[v] == nil then
            return false
        end
    end

    return true
end

--- Attempts to award a completion mark for the current character.
--- @param markName string
local function tryAwardMark(markName)
    local playerName = util.getCharacterName()
    local isTainted = util.isCharacterTainted()

    -- Get the completion marks data
    local marks = AP_SUPP_MOD:LoadKey("completion_marks", {})

    -- Ensure that the mark entry exists
    if marks[playerName] == nil then
        marks[playerName] = {}
    end

    marks[playerName][markName] = true

    -- Save 'em
    AP_SUPP_MOD:SaveKey("completion_marks", marks)

    -- Now, we award locations
    local locationName = playerName .. " (" .. markName .. ")"

    if not isTainted then -- Only for non-tainteds
        -- Check for "all marks"
        if hasAllMarks(marks[playerName]) then
            locationName = playerName .. " (All Marks)"
            Archipelago:sendLocation(Archipelago.LOCATIONS_DATA.NAME_TO_CODE[locationName])
        end
    
        Archipelago:sendLocation(Archipelago.LOCATIONS_DATA.NAME_TO_CODE[locationName])
        return
    end

    -- Award tainted's locations for the few specific marks that give them
    if singleTaintedLocations[markName] then
        Archipelago:sendLocation(Archipelago.LOCATIONS_DATA.NAME_TO_CODE[locationName])
    end

    -- Tainted characters have more specific logic

    -- Award tainted location for "main 4" bosses defeated
    if markName == "Isaac" or markName == "???" or markName == "Satan" or markName == "The Lamb" then
        if hasMain4BossMarks(marks[playerName]) then
            locationName = playerName .. " (Isaac, ???, Satan, The Lamb)"
            Archipelago:sendLocation(Archipelago.LOCATIONS_DATA.NAME_TO_CODE[locationName])
        end
    end

    if markName == "Hush" then
        if hasBossRushAndHush(marks[playerName]) then
            locationName = playerName .. " (Hush & Boss Rush)"
            Archipelago:sendLocation(Archipelago.LOCATIONS_DATA.NAME_TO_CODE[locationName])
        end
    end
end

--- Called when a boss is defeated, so the completion mark may be awarded.
--- @param entity Entity
Archipelago:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    local type = entity.Type
    local variant = entity.Variant
    local bossName = bossLocationNames[type]

    -- Not a completion mark enemy
    if bossName == nil then
        return
    end

    -- These bosses are variants, so they have to be selected specially
    if type == EntityType.ENTITY_ISAAC and variant == 1 then
        bossName = "???"
    elseif type == EntityType.ENTITY_ULTRA_GREED and variant == 1 then
        bossName = "Ultra Greedier"
    elseif type == EntityType.ENTITY_ISAAC and variant == 2 then
        return -- This is actually Hush's first form
    elseif type == EntityType.ENTITY_BEAST and variant ~= 0 then
        return -- This isn't the actual Beast
    elseif type == EntityType.ENTITY_MOTHER and variant ~= 10 then
        return -- This isn't Mother's second form
    end

    tryAwardMark(bossName)
end)

--- Fired when clearing boss rush.
Archipelago:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function ()
    if Archipelago.room():GetType() ~= RoomType.ROOM_BOSSRUSH then
        return
    end

    tryAwardMark("Boss Rush")
end)