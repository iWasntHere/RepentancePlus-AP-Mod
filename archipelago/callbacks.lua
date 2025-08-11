-- Provides callbacks for annoying operations
local util = require("archipelago.util")

--- For picking up pickups and opening chests.
--- @param pickup EntityPickup
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
    local data = pickup:GetData()

    -- Ensure that we have not already ran the callback for picking this up
    if data.archipelago_picked_up then

        -- Eternal Chests can re-close when opened
        if pickup.Variant == PickupVariant.PICKUP_ETERNALCHEST then
            local sprite = pickup:GetSprite()
            if sprite:IsPlaying("Idle") then
                data.archipelago_picked_up = false -- Unset that we've processed, so we can do it again
            else
                return
            end
        else
            return
        end
    end

    local sprite = pickup:GetSprite()

    if sprite:IsPlaying("Collect") then -- This is a regular pickup (heart, coin, bomb, etc)
        data.archipelago_picked_up = true

        Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PICKUP_PICKED, pickup)
    elseif sprite:IsPlaying("Open") then -- This is a chest
        data.archipelago_picked_up = true

        Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_CHEST_OPENED, pickup)
    end
end)

--- @type QueuedItemData
local lastFrameItem = nil

--- Handles picking up collectibles.
--- @param player EntityPlayer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    local queuedItem = player.QueuedItem

    -- Set the value for the last frame up properly
    if lastFrameItem == nil then
        lastFrameItem = queuedItem
    end

    -- Just started raising the item
    if lastFrameItem.Item == nil and queuedItem.Item ~= nil then
        if queuedItem.Item:IsCollectible() then
            Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PRE_GET_COLLECTIBLE, player, queuedItem.Item, queuedItem.Charge, queuedItem.Touched)
        end
    end

    -- The item is added
    if lastFrameItem.Item ~= nil and queuedItem.Item == nil then
        if lastFrameItem.Item:IsCollectible() then
            Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_POST_GET_COLLECTIBLE, player, lastFrameItem.Item, lastFrameItem.Charge, lastFrameItem.Touched)
        end
    end

    lastFrameItem = queuedItem
end)

local chapterEndStages = {
    [LevelStage.STAGE1_2] = true,
    [LevelStage.STAGE2_2] = true,
    [LevelStage.STAGE3_2] = true,
    [LevelStage.STAGE4_2] = true,
    [LevelStage.STAGE5] = true,
    [LevelStage.STAGE6] = true,
    [LevelStage.STAGE7] = true,
    [LevelStage.STAGE8] = true
}

--- Handles clearing floors and chapters.
--- @param rng RNG
--- @param spawnPosition Vector
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function (_, rng, spawnPosition)
    local level = Game():GetLevel()
    local room = level:GetCurrentRoom()

    -- This isn't the final boss room on this floor (Labyrinth), so disregard
    if not util.isChapterEndBoss(room) then
        return
    end

    local stage = level:GetStage()
    local stageType = level:GetStageType()

    Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_POST_FLOOR_CLEARED, stage, stageType)

    -- If labyrinth, then we are actually on stage + 1
    if level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH > 0 then
        stage = stage + 1
    end

    if not chapterEndStages[stage] then
        return
    end

    -- We completed a chapter!
    Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_POST_CHAPTER_CLEARED, stage, stageType)
end)