local util = Archipelago.util
local stats = Archipelago.stats
local incrementStat = stats.incrementStat
local StatKeys = stats.StatKeys
local Locations = Archipelago.LOCATIONS_DATA.LOCATIONS

--- Handles locations for completing chapters.
--- @param stage LevelStage
--- @param stageType StageType
Archipelago:AddCallback(Archipelago.Callbacks.MC_ARCHIPELAGO_POST_CHAPTER_CLEARED, function(_, stage, stageType)
    if Game():GetLevel():IsAscent() then -- Ascent should cancel all of this
        return
    end

    -- Get player name and chapter
    local playerName = util.getCharacterName()

    local chapterName = nil
    if stage == LevelStage.STAGE1_2 then
        chapterName = "Chapter 1"
    elseif stage == LevelStage.STAGE2_2 then
        chapterName = "Chapter 2"
    elseif stage == LevelStage.STAGE3_2 then
        chapterName = "Chapter 3"
    elseif stage == LevelStage.STAGE4_2 then
        chapterName = "Chapter 4"
    elseif stage == LevelStage.STAGE5 then
        chapterName = "Chapter 5"
    elseif stage == LevelStage.STAGE6 then
        chapterName = "Chapter 6"
    end

    -- This chapter isn't considered for locations
    if chapterName == nil then
        return
    end

    --- @type integer[]
    local locations = {}

    -- Location for clearing chapter
    local location = Archipelago.LOCATIONS_DATA.NAME_TO_CODE[chapterName .. " Cleared"]
    if location then
        locations[#locations + 1] = location
    end

    -- Grant locations for completing stages without damage
    local lastDamageStage = stats.getStat(StatKeys.LAST_FLOOR_WITH_DAMAGE, stage)
    if stage - lastDamageStage >= 2 then
        location = Archipelago.LOCATIONS_DATA.NAME_TO_CODE[chapterName .. " Cleared (No Damage)"]

        if location then
            locations[#locations + 1] = location
        end
    end

    -- Clear a chapter > 1 with 0.5 hearts
    local lastHPStage = stats.getStat(StatKeys.LAST_FLOOR_WITHOUT_HALF_HEART, stage)
    if stage - lastHPStage >= 2 then
        locations[#locations + 1] = Locations.CHAPTER_GREATER_THAN_1_CLEARED_W_ONLY_05_HEARTS
    end

    -- Chapter Clears as character
    location = Archipelago.LOCATIONS_DATA.NAME_TO_CODE[playerName .. " (" .. chapterName .. ")"]
    if location then
        locations[#locations + 1] = location
    end

    -- Clear whatever chapter like a billion times (these locations suck)
    local isNormalPath = stageType ~= StageType.STAGETYPE_REPENTANCE and stageType ~= StageType.STAGETYPE_REPENTANCE_B
    if isNormalPath then
        if stage == LevelStage.STAGE1_2 then
            if incrementStat(StatKeys.CHAPTER_1_CLEARS) >= 40 then -- 40 chapter 1 clears
                locations[#locations + 1] = Locations.BASEMENT_CLEARED_40X
            end
        elseif stage == LevelStage.STAGE2_2 then
            if incrementStat(StatKeys.CHAPTER_2_CLEARS) >= 30 then -- 30 chapter 2 clears
                locations[#locations + 1] = Locations.CHAPTER_2_CLEARED_30X
            end
        elseif stage == LevelStage.STAGE3_2 then
            if incrementStat(StatKeys.CHAPTER_3_CLEARS) >= 20 then -- 20 chapter 3 clears
                locations[#locations + 1] = Locations.CHAPTER_3_CLEARED_20X
            end
        end
    end

    Archipelago:sendLocations(locations)
end)

--- Used to reset the last time the player took damage.
--- @param continued boolean
Archipelago:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then
        return
    end

    stats.setStat(StatKeys.LAST_FLOOR_WITHOUT_HALF_HEART, 0)
    stats.setStat(StatKeys.LAST_FLOOR_WITH_DAMAGE, 0)
end)

--- Tracks the last time the player took damage.
--- @param entity Entity
--- @param amount number
--- @param damageFlags integer
--- @param source EntityRef
--- @param countdownFrames integer
Archipelago:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, amount, damageFlags, source, countdownFrames)
    stats.setStat(StatKeys.LAST_FLOOR_WITH_DAMAGE, Game():GetLevel():GetStage())
end, EntityType.ENTITY_PLAYER)

--- Tracks the last time the player had with more than one half heart
--- @param player EntityPlayer
Archipelago:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    if util.totalPlayerHealth(player) <= 1 then
        return
    end

    local stage = Game():GetLevel():GetStage()
    local lastWithoutHalfHeart = stats.getStat(StatKeys.LAST_FLOOR_WITHOUT_HALF_HEART, 0)

    -- Only save if the value was updated
    if stage ~= lastWithoutHalfHeart then
        stats.setStat(StatKeys.LAST_FLOOR_WITHOUT_HALF_HEART, lastWithoutHalfHeart)
    end
end)