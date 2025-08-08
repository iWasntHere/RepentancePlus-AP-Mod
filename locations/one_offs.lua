local util = require("util")

--- @enum StatKeys
local StatKeys = {
    GULP_USES_THIS_RUN = "gulps",
    ARCADE_VISITED_THIS_FLOOR = "arcade_visited_this_floor",
    LOCKED_CHESTS_OPENED = "locked_chests_opened",
    CARDS_USED = "cards_used",
    DEATH_CARDS_USED = "death_cards_used",
    TOTAL_DEATHS = "total_deaths",
    ARCADES_VISITED = "arcades_visited",
    LIL_BATTERIES_PICKED = "lil_batteries_picked"
}

--- Increases the given stat by 1, and returns the new value.
--- @param statKey StatKeys
--- @return integer
local function incrementStat(statKey)
    local value = AP_SUPP_MOD:LoadKey(statKey, 0) + 1
    AP_SUPP_MOD:SaveKey(statKey, value)

    return value
end

--- Sets the given stat to the value.
--- @param statKey StatKeys
--- @param value any
local function setStat(statKey, value)
    AP_SUPP_MOD:SaveKey(statKey, value)
end

--- Gets the value of the stat key.
--- @param statKey StatKeys
--- @param default any
--- @return any
local function getStat(statKey, default)
    return AP_SUPP_MOD:LoadKey(statKey, default)
end

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then
        return
    end

    -- Reset these when a new game begins
    setStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.GULP_USES_THIS_RUN, 0)
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
        -- Use Gulp! 5 times in one run
        if incrementStat(StatKeys.GULP_USES_THIS_RUN) == 5 then
            AP_MAIN_MOD:sendLocation(470)
        end
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    local game = Game()

    -- Reset these when a new floor is reached
    setStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, false)

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
    if not getStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, false) and game:GetRoom():GetType() == RoomType.ROOM_ARCADE then
        setStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, true)

        if incrementStat(StatKeys.ARCADES_VISITED) == 10 then
            AP_MAIN_MOD:sendLocation(443)
        end
    end
end)

AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PICKUP_PICKED, function (_, pickup)
    if pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
        if incrementStat(StatKeys.LIL_BATTERIES_PICKED) == 20 then
            AP_MAIN_MOD:sendLocation(485) -- Collect 20 lil batteries
        end
    end
end)

AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_CHEST_OPENED, function (_, chest)
    if (chest.Variant == PickupVariant.PICKUP_LOCKEDCHEST) then
        if incrementStat(StatKeys.LOCKED_CHESTS_OPENED) == 20 then
            AP_MAIN_MOD:sendLocation(454) -- Open 20 locked chests
        end
    elseif (chest.Variant == PickupVariant.PICKUP_MOMSCHEST) then
        AP_MAIN_MOD:sendLocation(475) -- Open Mom's Chest
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, cardType, player, flags)
    -- 20 Cards or Runes used
    if incrementStat(StatKeys.CARDS_USED) == 20 then
        AP_MAIN_MOD:sendLocation(489)
    end

    if cardType == Card.CARD_DEATH then
        if incrementStat(StatKeys.DEATH_CARDS_USED) == 4 then
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
    if incrementStat(StatKeys.TOTAL_DEATHS) == 100 then
        AP_MAIN_MOD:sendLocation(445)
    end
end, EntityType.ENTITY_PLAYER)