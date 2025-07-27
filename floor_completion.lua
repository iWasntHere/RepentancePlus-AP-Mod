local util = require("util.lua")

-- Handles locations for completing floors
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(spawnPosition)
    local level = Game():GetLevel()
    local room = level:GetCurrentRoom()

    if room:GetType() ~= RoomType.ROOM_BOSS then
        return
    end

    -- Get player name and chapter
    local playerName = util.get_character_name()
    local stage = level:GetStage()

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

    -- If we have curse of the labyrinth, then we need to do extra checks
    if level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH > 0 then
        if stage == LevelStage.STAGE1_1 then
            chapterName = "Chapter 1"
        elseif stage == LevelStage.STAGE2_1 then
            chapterName = "Chapter 2"
        elseif stage == LevelStage.STAGE3_1 then
            chapterName = "Chapter 3"
        elseif stage == LevelStage.STAGE4_1 then
            chapterName = "Chapter 4"
        end
    end

    if chapterName == nil then
        return
    end

    local locationName = playerName .. " (" .. chapterName .. ")"
    local locationCode = AP_MAIN_MOD.LOCATIONS_DATA[locationName]

    Isaac.ConsoleOutput(locationName .. " " .. locationCode .. "\n")

    AP_MAIN_MOD:sendLocation(locationCode)
end)