local util = require("archipelago.util")
local runLocked = false
local characterLocked = false
local challengeLocked = false

--- Locks the run.
--- @param character boolean If the cause was because the character was locked
--- @param challenge boolean If the cause was because the challenge was locked
local function isLocked(character, challenge)
    runLocked = true

    if character then
        characterLocked = true
    elseif challenge then
        challengeLocked = true
    end

    -- Add costumes
    local player = Isaac.GetPlayer(0)
    if math.random() > 0.05 then
        util.addCostumeToPlayer(player, CollectibleType.COLLECTIBLE_SAD_ONION, true)
        util.addCostumeToPlayer(player, CollectibleType.COLLECTIBLE_CRICKETS_HEAD, true)
    else
        util.addCostumeToPlayer(player, CollectibleType.COLLECTIBLE_CHAOS, true) -- Very small chance for a trollface instead
    end

    -- Remove doors
    local room = Game():GetLevel():GetCurrentRoom()
    for slot, door in util.doors(room) do
        room:RemoveDoor(slot)
    end
end

--- Checks if the currently played character is locked, then applies locked code if it is.
local function checkCharacterLocked()
    local player = Isaac.GetPlayer(0)
    local character = player:GetPlayerType()

    local code = AP_MAIN_MOD.ITEMS_DATA.CHARACTER_ID_TO_CODE[character]

    if not AP_MAIN_MOD:checkUnlocked(code) then
        isLocked(true, false)
    else
        characterLocked = false -- In case we had previously determined it was
    end
end

--- Checks if the current challenge is locked, applies locked code if it is.
local function checkChallengeLocked()
    local challengeId = Game().Challenge

    -- Not doing a challenge
    if challengeId == 0 then
        challengeLocked = false
        return
    end

    local challengeName = AP_MAIN_MOD.CHALLENGE_DATA.CHALLENGE_ID_TO_NAME[challengeId]

    if not AP_MAIN_MOD:checkUnlockedByName(challengeName) then
        isLocked(false, true)
    else
        challengeLocked = false
    end
end

--- @param continued boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if Game():GetLevel():GetStage() ~= LevelStage.STAGE1_1 then -- Only do this when the run first starts. Prevents getting stuck with Clicker
        return
    end

    checkCharacterLocked()
    checkChallengeLocked()

    if not characterLocked and not challengeLocked then
        runLocked = false -- Neither is locked, run is free to go
    end
end)

local font = Font()
font:Load("font/terminus.fnt")
local flashValue = 0
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not runLocked then
        return
    end

    flashValue = flashValue + 1

    local width = Isaac.GetScreenWidth()
    local height = Isaac.GetScreenHeight()
    local flash = 0.75 + (math.sin(flashValue * 0.1) / 4)

    local text = "This character is locked!"
    if challengeLocked then
        text = "This challenge is locked!"
    end

    local textWidth = font:GetStringWidth(text)
    font:DrawString(text, (width / 2) - (textWidth / 2), height / 2, KColor(1, flash, flash, 1))
end)