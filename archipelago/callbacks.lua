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

--- Used to run callbacks for opening Mom's chest (specifically, yeah..)
--- @param pickup EntityPickup
--- @param collider Entity
--- @param low boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function (_, pickup, collider, low)
    if not collider:ToPlayer() then -- Collider wasn't a player
        return
    end

    Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_CHEST_OPENED, pickup)
end, PickupVariant.PICKUP_MOMSCHEST)

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

--- Handles detecting when EntitySlots die. It's a really bad algorithm, but, of course, there's no other way.
--- This is really only used for beggars (since they have no death animation)
--- @param entityType EntityType
--- @param variant integer
--- @param subType integer
--- @param position Vector
--- @param velocity Vector
--- @param spawnerEntity Entity|nil
--- @param seed integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, entityType, variant, subType, position, velocity, spawnerEntity, seed)
    if entityType ~= EntityType.ENTITY_EFFECT then
        return
    end

    if variant == EffectVariant.BOMB_EXPLOSION then
        for _, entity in ipairs(Isaac.FindInRadius(position, 75, EntityPartition.PICKUP)) do
            local sprite = entity:GetSprite()
            if not sprite or not sprite:IsPlaying("Broken") then -- For slots that actually have an animation for being dead, check the animation
                Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PRE_SLOT_KILLED, entity)
            end
        end
    end
end)

--- @type table<integer, integer>
local roomGridEntitySnapshot = {} -- Used to scan for changes, to see if a grid entity was destroyed. Index to state
local currentRoomIndex = 0 -- Used to scan for when the room changes so the snapshot can be cleared
--- Handles slot machine and grid entity events. Sigh.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    -- Slot events
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_SLOT then
            local data = entity:GetData()

            local sprite = entity:GetSprite()
            if not data.archipelago_game_ended then
                local prize = sprite:IsPlaying("Prize") or sprite:IsPlaying("Shell1Prize") or sprite:IsPlaying("Shell2Prize") or sprite:IsPlaying("Shell3Prize")
                local closetPlayerRescue = entity.Variant == 14 and sprite:IsPlaying("PayPrize") -- Isaac in Home closet

                -- If the prize animation is playing, set that the game ended
                if prize or closetPlayerRescue then
                    data.archipelago_game_ended = true

                    Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_SLOT_GAME_END, entity)
                end
            else
                -- If the game is set to ended and the sprite is in idle, then the game is reset for the next play
                if sprite:IsPlaying("Idle") then
                    data.archipelago_game_ended = false
                
                -- This occurs when a beggar pays out a collectible and leaves
                elseif sprite:IsPlaying("Teleport") and not data.archipelago_beggar_paid_out then
                    data.archipelago_beggar_paid_out = true
                    Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_BEGGAR_COLLECTIBLE_PAYOUT, entity)
                end
            end

            -- Fortune telling machines paying out with a fortune
            if entity.Variant == 3 and sprite:IsPlaying("Prize") then
                if sprite:GetFrame() == 4 then -- I'll be honest, I stole this code
                    local numNewEntities = util.getNewEntitiesThisFrame(EntityType.ENTITY_PICKUP)

                    if #numNewEntities == 0 then -- No entities were spawned as a result
                        Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_FORTUNE_TELLER_FORTUNE)
                    end
                end
            end
        end
    end

    -- Grid events
    local level = Game():GetLevel()
    local room = level:GetCurrentRoom()
    local roomIndex = level:GetCurrentRoomIndex()
    
    if roomIndex ~= currentRoomIndex then
        currentRoomIndex = roomIndex
        roomGridEntitySnapshot = {}
    end

    for index, gridEnt in util.gridEntities(room) do
        if gridEnt then
            local oldState = roomGridEntitySnapshot[index]

            -- If a grid entity's state was changed... (this includes being added)
            if gridEnt.State ~= oldState then
                Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_GRID_ENTITY_STATE_CHANGED, gridEnt, oldState)
            end

            roomGridEntitySnapshot[index] = gridEnt.State
        end
    end
end)

--- Used to detect when the Fortune Cookie pays out with a fortune.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_ITEM, function(_)
    local numNewEntities = util.getNewEntitiesThisFrame(EntityType.ENTITY_PICKUP)

    if #numNewEntities == 0 then -- No entities were spawned as a result
        Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_FORTUNE_TELLER_FORTUNE)
    end
end, CollectibleType.COLLECTIBLE_FORTUNE_COOKIE)

--- Used to run callbacks for sleeping.
--- @param pickup EntityPickup
--- @param collider Entity
--- @param low boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function (_, pickup, collider, low)
    if pickup.SubType == BedSubType.BED_MOM then -- Isaac's Bed only
        return
    end

    if pickup.Touched then -- Unused beds only please
        return
    end

    local player = collider:ToPlayer()

    if not player then -- Collider wasn't a player..?
        return
    end

    local maxHearts = player:GetEffectiveMaxHearts()

    -- We have to recreate the conditional for if you can sleep, of course...
    if maxHearts == 1 or player:GetHearts() < maxHearts then
        Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_BED_SLEEP)
    end
end, PickupVariant.PICKUP_BED)