local characterLocked = false

-- When a character is locked, all doors are removed
local function characterIsLocked()
    characterLocked = true

    local player = Isaac.GetPlayer(0)
    local room = Game():GetLevel():GetCurrentRoom()

    player:AddCollectible(CollectibleType.COLLECTIBLE_SAD_ONION)
    player:AddCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD)

    -- Add these to the twin as well
    local twin = player:GetOtherTwin()
    if twin ~= nil then
        twin:AddCollectible(CollectibleType.COLLECTIBLE_SAD_ONION)
        twin:AddCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD)
    end

    for i = 0, DoorSlot.NUM_DOOR_SLOTS, 1 do
        room:RemoveDoor(i)
    end
end

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if not continued then
        return
    end

    characterLocked = false
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    if Game():GetLevel():GetStage() > 1 then -- Only do this when the run first starts. Prevents getting stuck with Clicker
        return
    end

    local player = Isaac.GetPlayer(0)
    local character = player:GetPlayerType()

    local code = AP_MAIN_MOD.ITEMS_DATA.CHARACTER_ID_TO_CODE[character]

    if not AP_MAIN_MOD:checkUnlocked(code) then
        characterIsLocked()
    end
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