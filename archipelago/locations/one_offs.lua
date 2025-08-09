local util = require("archipelago.util")

--- @enum StatKeys
local StatKeys = {
    GULP_USES_THIS_RUN = "gulps_this_run",
    ARCADE_VISITED_THIS_FLOOR = "arcade_visited_this_floor",
    LOCKED_CHESTS_OPENED = "locked_chests_opened",
    CARDS_USED = "cards_used",
    DEATH_CARDS_USED = "death_cards_used",
    TOTAL_DEATHS = "total_deaths",
    ARCADES_VISITED = "arcades_visited",
    LIL_BATTERIES_PICKED = "lil_batteries_picked",
    SHOPS_VISITED_THIS_RUN = "shops_visited_this_run",
    SHOP_VISITED_THIS_FLOOR = "shop_visited_this_floor",
    ANGEL_ITEMS_TAKEN = "angel_items_taken",
    DEVIL_ITEMS_TAKEN = "devil_items_taken",
    DEVIL_ITEMS_TAKEN_THIS_RUN = "devil_items_taken_this_run",
    RUBBER_CEMENTS_COLLECTED = "rubber_cements_collected", -- Collect rubber cements
    BLOOD_CLOTS_COLLECTED = "blood_clots_collected", -- Collect blood clots
    SECRET_ROOM_VISITS = "secret_room_visits", -- Visit 50 secret rooms
    SECRET_ROOM_VISITED_THIS_FLOOR = "secret_room_visited_this_floor",
    SUPER_SECRET_ROOM_VISITED_THIS_FLOOR = "super_secret_room_visited_this_floor",
    ULTRA_SECRET_ROOM_VISITED_THIS_FLOOR = "ultra_secret_room_visited_this_floor",
    LAST_RUN_COMPLETED = "last_run_completed", -- Mr Resetter!
    RESETS = "resets", -- Mr Reseter!
    HEARTS_COINS_BOMBS_PICKED_THIS_RUN = "hearts_coins_bombs_picked_this_run", -- It's the Key!
    WIN_STREAK = "win_streak",
    TEARS_UP_PILLS_THIS_RUN = "tears_up_pills_this_run",
    DIED_THIS_RUN = "died_this_run" -- Lazarus @ Mom's Heart w/o Deaths
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

--- @param continued boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then
        return
    end

    -- Reset 7 times
    if not getStat(StatKeys.LAST_RUN_COMPLETED) then
        if incrementStat(StatKeys.RESETS) == 7 then
            AP_MAIN_MOD:sendLocation(461)
        end

        -- Invalidate the win streak
        setStat(StatKeys.WIN_STREAK, 0)
    end

    -- Reset these when a new game begins
    setStat(StatKeys.SECRET_ROOM_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.SUPER_SECRET_ROOM_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.ULTRA_SECRET_ROOM_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.SHOP_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.SHOPS_VISITED_THIS_RUN, 0)
    setStat(StatKeys.GULP_USES_THIS_RUN, 0)
    setStat(StatKeys.DEVIL_ITEMS_TAKEN_THIS_RUN, 0)
    setStat(StatKeys.LAST_RUN_COMPLETED, false)
    setStat(StatKeys.HEARTS_COINS_BOMBS_PICKED_THIS_RUN, false)
    setStat(StatKeys.TEARS_UP_PILLS_THIS_RUN, 0)
    setStat(StatKeys.DIED_THIS_RUN, false)
end)

--- @param player EntityPlayer
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

    -- Have 20 or more blue flies at once
    if player:GetNumBlueFlies() >= 20 then
        AP_MAIN_MOD:sendLocation(472)
    end
end)

--- @param itemType CollectibleType
--- @param player EntityPlayer
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

--- @param pillEffect PillEffect
--- @param player EntityPlayer
--- @param flags integer
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
    setStat(StatKeys.SECRET_ROOM_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.SUPER_SECRET_ROOM_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.ULTRA_SECRET_ROOM_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, false)
    setStat(StatKeys.SHOP_VISITED_THIS_FLOOR, false)


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
    local roomType = game:GetRoom():GetType()

    -- Visit 10 arcades
    if not getStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_ARCADE then
        setStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, true)

        if incrementStat(StatKeys.ARCADES_VISITED) == 10 then
            AP_MAIN_MOD:sendLocation(443)
        end
    end

    -- Visit 6 shops in one run
    if not getStat(StatKeys.SHOP_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_SHOP then
        setStat(StatKeys.SHOP_VISITED_THIS_FLOOR, true)

        if incrementStat(StatKeys.SHOPS_VISITED_THIS_RUN) == 6 then
            AP_MAIN_MOD:sendLocation(465)
        end
    end

    if not getStat(StatKeys.SECRET_ROOM_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_SECRET then
        incrementStat(StatKeys.SECRET_ROOM_VISITS)
    end

    if not getStat(StatKeys.SUPER_SECRET_ROOM_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_SUPERSECRET then
        incrementStat(StatKeys.SECRET_ROOM_VISITS)
    end

    if not getStat(StatKeys.ULTRA_SECRET_ROOM_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_ULTRASECRET then
        incrementStat(StatKeys.SECRET_ROOM_VISITS)
    end

    -- Visit 50 secret rooms
    if getStat(StatKeys.SECRET_ROOM_VISITS, 0) >= 50 then
        AP_MAIN_MOD:sendLocation(462)
    end
end)

--- @param pickup EntityPickup
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PICKUP_PICKED, function (_, pickup)
    if pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
        if incrementStat(StatKeys.LIL_BATTERIES_PICKED) == 20 then
            AP_MAIN_MOD:sendLocation(485) -- Collect 20 lil batteries
        end
    end

    -- Failed It's the Key! :( (This achievement sucks so bad)
    if pickup.Variant == PickupVariant.PICKUP_HEART or pickup.Variant == PickupVariant.PICKUP_BOMB or pickup.Variant == PickupVariant.PICKUP_COIN then
        setStat(StatKeys.HEARTS_COINS_BOMBS_PICKED_THIS_RUN, true)
    end
end)

--- @param chest EntityPickup
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_CHEST_OPENED, function (_, chest)
    if (chest.Variant == PickupVariant.PICKUP_LOCKEDCHEST) then
        if incrementStat(StatKeys.LOCKED_CHESTS_OPENED) == 20 then
            AP_MAIN_MOD:sendLocation(454) -- Open 20 locked chests
        end
    elseif (chest.Variant == PickupVariant.PICKUP_MOMSCHEST) then
        AP_MAIN_MOD:sendLocation(475) -- Open Mom's Chest
    end
end)

--- @param cardType Card
--- @param player EntityPlayer
--- @param flags integer
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

--- When the player dies
--- @param player EntityPlayer
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

    setStat(StatKeys.DIED_THIS_RUN, true)
end, EntityType.ENTITY_PLAYER)

--- When The Lamb dies (It's the Key!)
--- @param entity EntityNPC
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    if not getStat(StatKeys.HEARTS_COINS_BOMBS_PICKED_THIS_RUN, true) then
        AP_MAIN_MOD:sendLocation(460)
    end
end, EntityType.ENTITY_THE_LAMB)

--- When Mom's Heart dies (Lazarus to Mom's Heart w/o Deaths)
--- @param entity EntityNPC
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    if not getStat(StatKeys.DIED_THIS_RUN, true) and Isaac.GetPlayer(0):GetType() == PlayerType.PLAYER_LAZARUS then
        AP_MAIN_MOD:sendLocation(358)
    end
end, EntityType.ENTITY_MOMS_HEART)

--- @param player EntityPlayer
--- @param item ItemConfigItem
--- @param charge integer
--- @param touched boolean
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PRE_GET_COLLECTIBLE, function (_, player, item, charge, touched)
    if touched then -- We only want to check for new items
        return
    end

    local roomType = Game():GetRoom():GetType()

    -- Pick up 10, 25 angel items
    if roomType == RoomType.ROOM_ANGEL then
        local taken = incrementStat(StatKeys.ANGEL_ITEMS_TAKEN)

        if taken == 10 then
            AP_MAIN_MOD:sendLocation(466)
        elseif taken == 25 then
            AP_MAIN_MOD:sendLocation(467)
        end
    end

    -- Pick up 20, 25, 30 devil items
    if roomType == RoomType.ROOM_DEVIL then
        local taken = incrementStat(StatKeys.DEVIL_ITEMS_TAKEN)
        
        if taken == 20 then
            AP_MAIN_MOD:sendLocation(450)
        elseif taken == 25 then
            AP_MAIN_MOD:sendLocation(451)
        elseif taken == 30 then
            AP_MAIN_MOD:sendLocation(452)
        end

        -- Pick up 3 devil items in one run
        if incrementStat(StatKeys.DEVIL_ITEMS_TAKEN_THIS_RUN) == 3 then
            AP_MAIN_MOD:sendLocation(449)
        end
    end
end)

---Determines if the player has fulfilled the "collect 10 tears up items or pills" condition, and sends the location
---@param player EntityPlayer
local function tryTearsUpCollectionLocation(player)
    -- Collect at least 10 tears up items or pills
    local tearsItems = util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.STARS)
    if tearsItems + getStat(StatKeys.TEARS_UP_PILLS_THIS_RUN, 0) >= 10 then
        AP_MAIN_MOD:sendLocation(464)
    end
end

--- @param player EntityPlayer
--- @param item ItemConfigItem
--- @param charge integer
--- @param touched boolean
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PRE_GET_COLLECTIBLE, function (_, player, item, charge, touched)
    if touched then -- We only want to check for new items
        return
    end

    -- Collected 5 Rubber Cements
    if item.ID == CollectibleType.COLLECTIBLE_RUBBER_CEMENT then
        if incrementStat(StatKeys.RUBBER_CEMENTS_COLLECTED) == 5 then
            AP_MAIN_MOD:sendLocation(430)
        end
    end

    -- Collected 10 Blood Clots
    if item.ID == CollectibleType.COLLECTIBLE_RUBBER_CEMENT then
        if incrementStat(StatKeys.RUBBER_CEMENTS_COLLECTED) == 10 then
            AP_MAIN_MOD:sendLocation(436)
        end
    end

   -- Own at least 50 collectibles
    if player:GetCollectibleCount() >= 50 then
        AP_MAIN_MOD:sendLocation(428)
    end

    -- Collect Key Piece 1 and 2
    if util.hasAllCollectibles(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.KEY_PIECES) then
        AP_MAIN_MOD:sendLocation(426)
    end

    -- Collect Battery, 9 Volt, Car Battery
    if util.hasAllCollectibles(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.SIMPLE_BATTERIES) then
        AP_MAIN_MOD:sendLocation(429)
    end

    -- Collect Broken Watch and Stop Watch
    if util.hasAllCollectibles(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.WATCH) then
        AP_MAIN_MOD:sendLocation(432)
    end

    -- Make a Super Meat Boy
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT, true) >= 4 then
        AP_MAIN_MOD:sendLocation(420)
    end

    -- Make a Super Bandage Girl
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES, true) >= 4 then
        AP_MAIN_MOD:sendLocation(419)
    end

    -- Collect at least 2 battery items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.BATTERY) >= 2 then
        AP_MAIN_MOD:sendLocation(424)
    end

    -- Collect at least 2 dead items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.DEAD) >= 2 then
        AP_MAIN_MOD:sendLocation(421)
    end

    -- Collect at least 3 mom items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.MOM) >= 2 then
        AP_MAIN_MOD:sendLocation(422)
    end

    -- Collect at least 2 technology items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.TECH) >= 2 then
        AP_MAIN_MOD:sendLocation(425)
    end

    -- Collect at least 3 celestial items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.STARS) >= 3 then
        AP_MAIN_MOD:sendLocation(427)
    end

    tryTearsUpCollectionLocation(player)

    -- Collect at least 5 familiars
    if util.countFollowerFamiliars() >= 5 then
        AP_MAIN_MOD:sendLocation(431)
    end
end)

--- Used to track when the player resets (starts a new run without finishing the last)
--- @param isGameOver boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_END, function (_, isGameOver)
    setStat(StatKeys.LAST_RUN_COMPLETED, true)

    -- Win streak!
    if isGameOver then
        setStat(StatKeys.WIN_STREAK, 0)
    else
        local wins = incrementStat(StatKeys.WIN_STREAK)

        -- 3 Win Streak
        if wins >= 3 then
            AP_MAIN_MOD:sendLocation(457)
        end

        -- 5 Win Streak
        if wins >= 5 then
            AP_MAIN_MOD:sendLocation(458)
        end
    end
end)

--- Used to track how many Tears Up pills were used this run
--- @param effect PillEffect
--- @param player EntityPlayer
--- @param flags integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_PILL, function (effect, player, flags)
    if effect == PillEffect.PILLEFFECT_TEARS_UP then
        incrementStat(StatKeys.TEARS_UP_PILLS_THIS_RUN)
        tryTearsUpCollectionLocation(player)
    end
end)