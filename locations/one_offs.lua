local util = require("util")

local function getDefaultRunStats()
    return {
        gulp_uses = 0
    }
end

local perRunStats = getDefaultRunStats()

--- Updates the given stat for this current run
--- @param key string The key that holds the value to update
--- @param value any The new value
local function updateRunStat(key, value)
    perRunStats[key] = value
    AP_SUPP_MOD:SaveKey("per_run_stats", perRunStats)
end

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then
        perRunStats = AP_SUPP_MOD:LoadKey("per_run_stats", getDefaultRunStats())
    end

    AP_SUPP_MOD:SaveKey("per_run_stats", getDefaultRunStats())

    AP_SUPP_MOD:SaveKey("arcade_visited_this_floor", false)
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    -- "Be Larger"
    if player:GetSprite().Scale.X > 1.9 then
        AP_MAIN_MOD:sendLocation(487)
    end

    -- Have 7 or more heart containers
    if player:GetEffectiveMaxHearts() >= 14 then
        AP_MAIN_MOD:sendLocation(436)
    end

    -- Have 55 or more coins
    if player:GetNumCoins() >= 55 then
        AP_MAIN_MOD:sendLocation(435)
    end

    -- Have 4 or more soul hearts
    if player:GetSoulHearts() >= 8 then
        AP_MAIN_MOD:sendLocation(434)
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, itemType, player)
    local level = Game():GetLevel()

    -- Use Pandora's Box in Dark Room
    if itemType == CollectibleType.COLLECTIBLE_BLUE_BOX and level:GetStage() == LevelStage.STAGE6 and level:GetStageType() == StageType.STAGETYPE_ORIGINAL then
        AP_MAIN_MOD:sendLocation(486)
    end

    -- Use Blank Card on The Sun
    if itemType == CollectibleType.COLLECTIBLE_BLANK_CARD and player:GetCard(0) == Card.CARD_SUN then
        AP_MAIN_MOD:sendLocation(480)
    end

    -- Bible used on Mom
    if itemType == CollectibleType.COLLECTIBLE_BIBLE then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_MOM then
                AP_MAIN_MOD:sendLocation(444)
            end
        end
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_PILL, function (_, pillEffect, player, flags)
    if pillEffect == PillEffect.PILLEFFECT_GULP then
        updateRunStat("gulp_uses", perRunStats.gulp_uses + 1)
    end

    -- Use Gulp! 5 times in one run
    if perRunStats.gulp_uses == 5 then
        AP_MAIN_MOD:sendLocation(470)
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    local game = Game()

    AP_SUPP_MOD:SaveKey("arcade_visited_this_floor", false)

    -- 2 stages cleared without damage
    if game:GetStagesWithoutDamage() >= 2 then
        AP_MAIN_MOD:sendLocation(438)
    end

    -- 2 stages cleared without picking up hearts
    if game:GetStagesWithoutHeartsPicked() >= 2 then
        AP_MAIN_MOD:sendLocation(437)
    end

    -- Enter the Corpse
    local level = game:GetLevel()
    if level:GetStage() == LevelStage.STAGE4_1 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
        AP_MAIN_MOD:sendLocation(433)
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    local game = Game()

    -- Visit 10 arcades
    if not AP_SUPP_MOD:LoadKey("arcade_visited_this_floor", false) and game:GetRoom():GetType() == RoomType.ROOM_ARCADE then
        AP_SUPP_MOD:SaveKey("arcade_visited_this_floor", true)

        local arcadesVisited = AP_SUPP_MOD:LoadKey("arcades_visited", 0) + 1
        AP_SUPP_MOD:SaveKey("arcades_visited", arcadesVisited)

        if arcadesVisited == 10 then
            AP_MAIN_MOD:sendLocation(443)
        end
    end
end)

local checkingPickupVariants = {
    [PickupVariant.PICKUP_LOCKEDCHEST] = true,
    [PickupVariant.PICKUP_MOMSCHEST] = true
}

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
    if not checkingPickupVariants[pickup.Variant] then -- Not the chest we're looking for
        return
    end

    local data = pickup:GetData()

    if not data.archipelago_pickup_processed then -- We haven't processed this chest yet
        local sprite = pickup:GetSprite()

        if sprite:IsPlaying("Open") then
            data.archipelago_pickup_processed = true -- Processed now

            if pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST then
                local chestsOpened = AP_SUPP_MOD:LoadKey("locked_chests_opened", 0) + 1
                AP_SUPP_MOD:SaveKey("locked_chests_opened", chestsOpened)

                if chestsOpened == 20 then
                    AP_MAIN_MOD:sendLocation(454) -- Open 20 locked chests
                end
            elseif pickup.Variant == PickupVariant.PICKUP_MOMSCHEST then
                AP_MAIN_MOD:sendLocation(475) -- Open Mom's Chest
            end
        end
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, cardType, player, flags)
    local cardsUsed = AP_SUPP_MOD:LoadKey("cards_used", 0) + 1
    AP_SUPP_MOD:SaveKey("cards_used", cardsUsed)

    -- 20 Cards or Runes used
    if cardsUsed == 20 then
        AP_MAIN_MOD:sendLocation(489)
    end

    if cardType == Card.CARD_DEATH then
        local deathUses = AP_SUPP_MOD:LoadKey("death_used", 0) + 1
        AP_SUPP_MOD:SaveKey("death_used", deathUses)

        if deathUses == 4 then
            AP_MAIN_MOD:sendLocation(446)
        end
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, player)
    -- Died in Sacrifice Room w/ Missing Poster
    if Game():GetRoom():GetType() == RoomType.ROOM_SACRIFICE then
        if util.hasTrinket(player, TrinketType.TRINKET_MISSING_POSTER) then
            AP_MAIN_MOD:sendLocation(439)
        end
    end

    -- Die 100 times
    local timesDied = AP_SUPP_MOD:LoadKey("deaths", 0) + 1
    AP_SUPP_MOD:SaveKey("deaths", timesDied)

    if timesDied == 100 then
        AP_MAIN_MOD:sendLocation(445)
    end
end, EntityType.ENTITY_PLAYER)