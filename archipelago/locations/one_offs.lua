local util = require("archipelago.util")
local stats = require("archipelago.stats")
local setStat = stats.setStat
local getStat = stats.getStat
local incrementStat = stats.incrementStat
local StatKeys = stats.StatKeys

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

    -- Bible used on Mom
    if itemType == CollectibleType.COLLECTIBLE_BIBLE then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_MOM then
                AP_MAIN_MOD:sendLocation(444)
            end
        end
    end
end)

--- @param cardType Card
--- @param player EntityPlayer
--- @param flags integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, cardType, player, flags)
    -- Use Blank Card on The Sun
    if cardType == Card.CARD_SUN and flags & UseFlag.USE_MIMIC ~= 0 then
        AP_MAIN_MOD:sendLocation(480)
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

    -- Visit 6 shops in one run (no greed mode)
    if not Game():IsGreedMode() and not getStat(StatKeys.SHOP_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_SHOP then
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

--- Tracks destroying the Siren's skull.
--- @param entity Entity
--- @param amount number
--- @param damageFlags integer
--- @param source EntityRef
--- @param countdownFrames integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, amount, damageFlags, source, countdownFrames)
    -- Blow up Siren's skull
    if entity.Type == EntityType.ENTITY_SIREN and entity.Variant == 1 then
        AP_MAIN_MOD:sendLocation(474)
    end
end, EntityType.ENTITY_SIREN)

--- Tracks destroying shopkeepers.
--- @param entity Entity
--- @param amount number
--- @param damageFlags integer
--- @param source EntityRef
--- @param countdownFrames integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, amount, damageFlags, source, countdownFrames)
    if incrementStat(StatKeys.SHOPKEEPERS_KILLED) == 20 then
        AP_MAIN_MOD:sendLocation(447)
    end
end, EntityType.ENTITY_SHOPKEEPER)

--- Tracks destroying slot machines and beggars.
--- @param entity Entity
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PRE_SLOT_KILLED, function (_, entity)
    -- Blow up Battery Bum 10 times
    if entity.Variant == 13 then
        if incrementStat(StatKeys.BATTERY_BUMS_KILLED) == 10 then
            AP_MAIN_MOD:sendLocation(477)
        end

    -- Blow up 30 slot machines
    elseif entity.Variant == 1 then
        if incrementStat(StatKeys.SLOT_MACHINES_KILLED) == 30 then
            AP_MAIN_MOD:sendLocation(456)
        end
    end
end)

--- Tracks beggars paying out collectibles.
--- @param entity Entity
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_BEGGAR_COLLECTIBLE_PAYOUT, function (_, entity)
    -- Get 5 collectible payouts from a Battery Bum
    if entity.Variant == 13 and incrementStat(StatKeys.BATTERY_BUM_COLLECTIBLE_PAYOUTS) == 5 then
        AP_MAIN_MOD:sendLocation(476)
    end
end)

--- Tracks playing shell games and slot machines.
--- @param entity Entity
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_SLOT_GAME_END, function (_, entity)
    local isShellGame = entity.Variant == 6 or entity.Variant == 15

    -- Play shell game 100 times
    if isShellGame and incrementStat(StatKeys.SHELL_GAME_PLAYS) == 100 then
        AP_MAIN_MOD:sendLocation(448)

    -- Donate blood 30 times
    elseif entity.Variant == 2 and incrementStat(StatKeys.BLOOD_DONATIONS) == 30 then
        AP_MAIN_MOD:sendLocation(455)
    end
end)

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

--- Determines if the player has fulfilled the "collect 10 tears up items or pills" condition, and sends the location
--- @param player EntityPlayer
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
    if util.countFamiliars() >= 5 then
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
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_PILL, function (_, effect, player, flags)
    if effect == PillEffect.PILLEFFECT_TEARS_UP then
        incrementStat(StatKeys.TEARS_UP_PILLS_THIS_RUN)
        tryTearsUpCollectionLocation(player)
    end
end)

local GridState = {
    ROCK_DESTROYED = 2,
    POOP_DESTROYED = 1000
}

local GridRockTypes = {
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCK_GOLD] = true,
    [GridEntityType.GRID_ROCK_SPIKED] = true,
    [GridEntityType.GRID_ROCK_SS] = true
}

--- Used to track destruction of grid entities.
--- @param gridEntity GridEntity
--- @param oldState integer
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_GRID_ENTITY_STATE_CHANGED, function (_, gridEntity, oldState)
    local type = gridEntity:GetType()
    local variant = gridEntity:GetVariant()

    if type == GridEntityType.GRID_POOP and gridEntity.State == GridState.POOP_DESTROYED then
        -- Destroy 5 rainbow poops
        if variant == 4 and incrementStat(StatKeys.RAINBOW_POOPS_DESTROYED) == 5 then
            AP_MAIN_MOD:sendLocation(484)
        end

        -- Destroy 100 poops
        if incrementStat(StatKeys.POOPS_DESTROYED) == 100 then
            AP_MAIN_MOD:sendLocation(453)
        end
    elseif GridRockTypes[type] and gridEntity.State == GridState.ROCK_DESTROYED then
        local rocksDestroyed = incrementStat(StatKeys.ROCKS_DESTROYED)

        if rocksDestroyed == 100 then -- Destroy 100 rocks
            AP_MAIN_MOD:sendLocation(482)
        elseif rocksDestroyed == 500 then -- Destroy 500 rocks
            AP_MAIN_MOD:sendLocation(483)
        end

        if type == GridEntityType.GRID_ROCKT or type == GridEntityType.GRID_ROCK_SS then
            local tintedRocksDestroyed = incrementStat(StatKeys.TINTED_ROCKS_DESTROYED)

            if tintedRocksDestroyed == 10 then -- Destroy 10 tinted rocks
                AP_MAIN_MOD:sendLocation(441)
            elseif tintedRocksDestroyed == 100 then -- Destroy 100 tinted rocks
                AP_MAIN_MOD:sendLocation(442)
            end
        end
    end
end)