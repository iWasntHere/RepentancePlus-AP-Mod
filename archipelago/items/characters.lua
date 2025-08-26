local util = Archipelago.util
local font = Archipelago.fonts.Terminus
local runLocked = false
local characterLocked = false
local challengeLocked = false
local greedierLocked = false

--- Locks the run.
--- @param character boolean If the cause was because the character was locked
--- @param challenge boolean If the cause was because the challenge was locked
--- @param greedier boolean If the cause was because greedier was locked
local function isLocked(character, challenge, greedier)
    runLocked = true

    if character then
        characterLocked = true
    elseif challenge then
        challengeLocked = true
    elseif greedier then
        greedierLocked = true
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
    local room = Archipelago.room()
    for slot, door in util.doors(room) do
        room:RemoveDoor(slot)
    end

    -- Remove the greed mode button
    for index, gridEntity in util.gridEntities(room) do
        if gridEntity and gridEntity:GetType() == GridEntityType.GRID_PRESSURE_PLATE and gridEntity:GetVariant() == 2 then
            room:RemoveGridEntity(index, 0, true)
            gridEntity:Update()
        end
    end

    room:Update()
end

--- Checks if the currently played character is locked, then applies locked code if it is.
local function checkCharacterLocked()
    local player = Isaac.GetPlayer(0)
    local character = player:GetPlayerType()

    local code = Archipelago.ITEMS_DATA.CHARACTER_ID_TO_CODE[character]

    if not Archipelago:checkUnlocked(code) then
        isLocked(true, false, false)
    else
        characterLocked = false -- In case we had previously determined it was
    end
end

--- Checks if the current challenge is locked, applies locked code if it is.
local function checkChallengeLocked()
    local challengeId = Archipelago.game.Challenge

    -- Not doing a challenge
    if challengeId == 0 then
        challengeLocked = false
        return
    end

    local challengeName = Archipelago.CHALLENGE_DATA.CHALLENGE_ID_TO_NAME[challengeId]

    if not Archipelago:checkUnlockedByName(challengeName) then
        isLocked(false, true, false)
    else
        challengeLocked = false
    end
end

--- Checks if the greedier mode is locked, and we're in it.
local function checkGreedierLocked()
    -- Not playing Greedier
    if Archipelago.game.Difficulty ~= Difficulty.DIFFICULTY_GREEDIER then
        greedierLocked = false
        return
    end

    if not Archipelago:checkUnlocked(Archipelago.ITEMS_DATA.NAME_TO_CODE["Greedier!"]) then
        isLocked(false, false, true)
    else
        greedierLocked = false -- In case we had previously determined it was
    end
end

--- @param continued boolean
Archipelago:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if Archipelago.level():GetStage() ~= LevelStage.STAGE1_1 then -- Only do this when the run first starts. Prevents getting stuck with Clicker
        return
    end

    checkCharacterLocked()
    checkChallengeLocked()
    checkGreedierLocked()

    if not characterLocked and not challengeLocked and not greedierLocked then
        runLocked = false -- Neither is locked, run is free to go
    end
end)

local flashValue = 0
Archipelago:AddCallback(ModCallbacks.MC_POST_RENDER, function()
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
    elseif greedierLocked then
        text = "Greedier Mode is locked!"
    end

    local textWidth = font:GetStringWidth(text)
    font:DrawString(text, (width / 2) - (textWidth / 2), height / 2, KColor(1, flash, flash, 1))
end)