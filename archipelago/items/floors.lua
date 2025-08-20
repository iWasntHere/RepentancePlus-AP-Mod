local util = Archipelago.util

local stageNames = {
    ["1-" .. tostring(StageType.STAGETYPE_ORIGINAL)] = "Basement",
    ["1-" .. tostring(StageType.STAGETYPE_WOTL)] = "The Cellar",
    ["1-" .. tostring(StageType.STAGETYPE_AFTERBIRTH)] = "Burning Basement",
    ["1-" .. tostring(StageType.STAGETYPE_REPENTANCE)] = "Downpour",
    ["1-" .. tostring(StageType.STAGETYPE_REPENTANCE_B)] = "Dross",

    ["2-" .. tostring(StageType.STAGETYPE_ORIGINAL)] = "Caves",
    ["2-" .. tostring(StageType.STAGETYPE_WOTL)] = "The Catacombs",
    ["2-" .. tostring(StageType.STAGETYPE_AFTERBIRTH)] = "Flooded Caves",
    ["2-" .. tostring(StageType.STAGETYPE_REPENTANCE)] = "Mines",
    ["2-" .. tostring(StageType.STAGETYPE_REPENTANCE_B)] = "Ashpit",

    ["3-" .. tostring(StageType.STAGETYPE_ORIGINAL)] = "Depths",
    ["3-" .. tostring(StageType.STAGETYPE_WOTL)] = "The Necropolis",
    ["3-" .. tostring(StageType.STAGETYPE_AFTERBIRTH)] = "Dank Depths",
    ["3-" .. tostring(StageType.STAGETYPE_REPENTANCE)] = "Mausoleum",
    ["3-" .. tostring(StageType.STAGETYPE_REPENTANCE_B)] = "Gehenna",

    ["4-" .. tostring(StageType.STAGETYPE_ORIGINAL)] = "The Womb",
    ["4-" .. tostring(StageType.STAGETYPE_WOTL)] = "Utero",
    ["4-" .. tostring(StageType.STAGETYPE_AFTERBIRTH)] = "Scarred Womb",
    ["4-" .. tostring(StageType.STAGETYPE_REPENTANCE)] = "Corpse"
}

local chapterStageGroups = {
    ["1-Main"] = {
        {name = "Basement", letter = ""},
        {name = "The Cellar", letter = "a"},
        {name = "Burning Basement", letter = "b"}
    },
    ["1-Alt"] = {
        {name = "Downpour", letter = "c"},
        {name = "Dross", letter = "d"},
    },
    ["2-Main"] = {
        {name = "Caves", letter = ""},
        {name = "The Catacombs", letter = "a"},
        {name = "Flooded Caves", letter = "b"}
    },
    ["2-Alt"] = {
        {name = "Mines", letter = "c"},
        {name = "Ashpit", letter = "d"},
    },
    ["3-Main"] = {
        {name = "Depths", letter = ""},
        {name = "The Necropolis", letter = "a"},
        {name = "Dank Depths", letter = "b"}
    },
    ["3-Alt"] = {
        {name = "Mausoleum", letter = "c"},
        {name = "Gehenna", letter = "d"},
    },
    ["4-Main"] = {
        {name = "The Womb", letter = ""},
        {name = "Utero", letter = "a"},
        {name = "Scarred Womb", letter = "b"}
    }
}

local stageToChapter = {
    [LevelStage.STAGE1_1] = "1",
    [LevelStage.STAGE1_2] = "1",
    [LevelStage.STAGE2_1] = "2",
    [LevelStage.STAGE2_2] = "2",
    [LevelStage.STAGE3_1] = "3",
    [LevelStage.STAGE3_2] = "3",
    [LevelStage.STAGE4_1] = "4",
    [LevelStage.STAGE4_2] = "4"
}

local stageTypeToPath = {
    [StageType.STAGETYPE_ORIGINAL] = "Main",
    [StageType.STAGETYPE_WOTL] = "Main",
    [StageType.STAGETYPE_AFTERBIRTH] = "Main",
    [StageType.STAGETYPE_REPENTANCE] = "Alt",
    [StageType.STAGETYPE_REPENTANCE_B] = "Alt",
}

Archipelago:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    local level = Archipelago.level()
    local stage = level:GetStage()
    local stageType = level:GetStageType()

    local chapterString = stageToChapter[stage]

    if chapterString == nil then -- We're on a floor that has no alts
        return
    end

    local stageKey = chapterString .. "-" .. tostring(stageType)
    local stageName = stageNames[stageKey]

    local code = Archipelago.ITEMS_DATA.NAME_TO_CODE[stageName]
    if code == nil then -- This floor isn't an item, so it's always unlocked
        return
    end

    if Archipelago:checkUnlocked(code) then -- Floor is unlocked so we do nothing
        return
    end

    local path = stageTypeToPath[stageType]

    local stageGroup = chapterStageGroups[chapterString .. "-" .. path]

    if stageGroup == nil then -- There are no alts for this chapter (Alt Path Womb reaches this)
        return
    end

    -- We'll need to create a copy of this table since we're going to shuffle it
    stageGroup = util.shallowCopyTable(stageGroup)
    util.shuffleTable(util.getRNG(), stageGroup)

    -- Now, we run down the list until we find the first unlocked stage.
    for _, stageData in ipairs(stageGroup) do
        local code = Archipelago.ITEMS_DATA.NAME_TO_CODE[stageData.name]

        -- If the stage isn't an item, or the stage is unlocked, then switch to it
        if code == nil or Archipelago:checkUnlocked(code) then
            Isaac.ExecuteCommand("stage " .. tostring(stage) .. stageData.letter)
            return
        end
    end

end)

local repStageTypes = {
    [StageType.STAGETYPE_REPENTANCE] = true,
    [StageType.STAGETYPE_REPENTANCE_B] = true
}

-- Set when the room is completed. Set false on update below. Used to clear Void portals.
local roomJustCompleted = false

--- Ends the game early in most cases, prevents entry to The Void from Hush.
--- @param rng RNG
--- @param spawnPosition Vector
Archipelago:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng, spawnPosition)
    local level = Archipelago.level()
    local room = Archipelago.room()

    local stage = util.getEffectiveStage(level)
    local isAltPath = repStageTypes[level:GetStageType()] ~= nil

    local isFinal = util.isChapterEndBoss(room)

    -- This is the Mom! fight
    if stage == LevelStage.STAGE3_2 and not isAltPath and isFinal then
        if not Archipelago:checkUnlockedByName("The Womb") then
            -- Spawn the chest!
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BIGCHEST, 0, spawnPosition, Vector(0, 0), nil)
            return true -- Cancel regular spawning
        end
    end

    -- This is the Mom's Heart fight
    if stage == LevelStage.STAGE4_2 and not isAltPath and isFinal then
        if not Archipelago:checkUnlockedByName("Blue Womb") then -- Blue Womb door
            util.removeSecretExit(room)
        end

        if not Archipelago:checkUnlockedByName("It Lives!") then
            -- Spawn the chest!
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BIGCHEST, 0, spawnPosition, Vector(0, 0), nil)
            return true -- Cancel regular spawning
        end
    end

    -- This is the Hush fight
    if stage == LevelStage.STAGE4_3 and isFinal then
        if not Archipelago:checkUnlockedByName("New Area") then -- Void door
            util.removeSecretExit(room)
        end

        if not Archipelago:checkUnlockedByName("It Lives!") then
            -- Spawn the chest!
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BIGCHEST, 0, spawnPosition, Vector(0, 0), nil)
            return true -- Cancel regular spawning
        end
    end

    -- This is a regular boss fight, remove Secret Exit
    if room:GetType() == RoomType.ROOM_BOSS then
        if not Archipelago:checkUnlockedByName("A Secret Exit") then
            util.removeSecretExit(room)
        end
    end

    roomJustCompleted = true
end)

--- Used to remove the Void trapdoor after you complete a boss fight.
Archipelago:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if not roomJustCompleted then
        return
    end

    roomJustCompleted = false

    local room = Archipelago.room()

    -- Loop over all grid positions, remove any Void trapdoors found
    for gridIndex = 0, room:GetGridSize(), 1 do
        local gridEntity = room:GetGridEntity(gridIndex)

        -- '1' is the variant for Void trapdoor
        if gridEntity and gridEntity:GetType() == GridEntityType.GRID_TRAPDOOR and gridEntity:GetVariant() == 1 then
            room:RemoveGridEntity(gridIndex, 0, true)
        end
    end
end)

--- Used to remove various doors.
Archipelago:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local level = Archipelago.level()
    local room = Archipelago.room()
    local roomType = room:GetType()

    -- Remove blue womb door
    if roomType == RoomType.ROOM_BOSS and util.getEffectiveStage(level) == LevelStage.STAGE4_2 then
        if not Archipelago:checkUnlockedByName("Blue Womb") then
            util.removeSecretExit(room)
            return
        end
    end

    -- Remove void door
    if roomType == RoomType.ROOM_BOSS and level:GetStage() == LevelStage.STAGE4_3 then
        if not Archipelago:checkUnlockedByName("New Area") then
            util.removeSecretExit(room)
            return
        end
    end

    -- Remove alt path entrance when you re-enter
    if roomType == RoomType.ROOM_BOSS and not Archipelago:checkUnlockedByName("A Secret Exit") then
        util.removeSecretExit(room)
        return
    end

    -- Remove ascent path entrance
    if roomType == RoomType.ROOM_DEFAULT and not Archipelago:checkUnlockedByName("A Strange Door") then
        util.removeSecretExit(room)
        return
    end
end)