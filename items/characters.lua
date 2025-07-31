local util = require("util")
local characterLocked = false

-- When a character is locked, all doors are removed
local function characterIsLocked()
    characterLocked = true

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
    for i = 0, DoorSlot.NUM_DOOR_SLOTS, 1 do
        room:RemoveDoor(i)
    end
end

-- Checks if the currently played character is locked, then applies locked code if it is
local function checkCharacterLocked()
    local player = Isaac.GetPlayer(0)
    local character = player:GetPlayerType()

    local code = AP_MAIN_MOD.ITEMS_DATA.CHARACTER_ID_TO_CODE[character]

    if not AP_MAIN_MOD:checkUnlocked(code) then
        characterIsLocked()
    else
        characterLocked = false -- In case we had previously determined it was
    end
end

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then -- Only do this when the run first starts. Prevents getting stuck with Clicker
        return
    end

    checkCharacterLocked()
end)

local font = Font()
font:Load("font/terminus.fnt")
local flashValue = 0
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not characterLocked then
        return
    end

    flashValue = flashValue + 1

    local width = Isaac.GetScreenWidth()
    local height = Isaac.GetScreenHeight()
    local flash = 0.75 + (math.sin(flashValue * 0.1) / 4)

    local textWidth = font:GetStringWidth("This character is locked!")
    font:DrawString("This character is locked!", (width / 2) - (textWidth / 2), height / 2, KColor(1, flash, flash, 1))
end)