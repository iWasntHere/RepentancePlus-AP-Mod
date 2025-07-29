local util = require "util"
local FloorItemNames = {
    "The Womb",
    "Blue Womb",
    "New Area",

    "The Cellar",
    "The Catacombs",
    "The Necropolis",

    "Burning Basement",
    "Flooded Caves",
    "Dank Depths",
    "Scarred Womb",

    "Dross",
    "Ashpit",
    "Gehenna"
}

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

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    local level = Game():GetLevel()
    local stage = level:GetStage()
    local stageType = level:GetStageType()

    local chapterString = stageToChapter[stage]

    if chapterString == nil then -- We're on a floor that has no alts
        return
    end

    local stageKey = chapterString .. "-" .. tostring(stageType)
    local stageName = stageNames[stageKey]

    local code = AP_MAIN_MOD.ITEMS_DATA.NAME_TO_CODE[stageName]
    if code == nil then -- This floor isn't an item, so it's always unlocked
        return
    end

    if AP_MAIN_MOD:checkUnlocked(code) then -- Floor is unlocked so we do nothing
        return
    end

    local path = stageTypeToPath[stageType]

    local stageGroup = chapterStageGroups[chapterString .. "-" .. path]

    if stageGroup == nil then -- There are no alts for this chapter (Alt Path Womb reaches this)
        return
    end

    -- We'll need to create a copy of this table since we're going to shuffle it
    stageGroup = util.shallow_copy_table(stageGroup)
    util.shuffle_table(util.getRNG(), stageGroup)

    -- Now, we run down the list until we find the first unlocked stage.
    for _, stageData in ipairs(stageGroup) do
        local code = AP_MAIN_MOD.ITEMS_DATA.NAME_TO_CODE[stageData.name]

        -- If the stage isn't an item, or the stage is unlocked, then switch to it
        if code == nil or AP_MAIN_MOD:checkUnlocked(code) then
            Isaac.ExecuteCommand("stage " .. tostring(stage) .. stageData.letter)
            return
        end
    end

end)