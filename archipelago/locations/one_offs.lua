local util = require("archipelago.util")
local stats = require("archipelago.stats")
local setStat = stats.setStat
local getStat = stats.getStat
local incrementStat = stats.incrementStat
local StatKeys = stats.StatKeys
local Locations = AP_MAIN_MOD.LOCATIONS_DATA.LOCATIONS

--- @param continued boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then
        return
    end

    -- Reset 7 times
    if not getStat(StatKeys.LAST_RUN_COMPLETED) then
        if incrementStat(StatKeys.RESETS) == 7 then
            AP_MAIN_MOD:sendLocation(Locations.RESET_7X)
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

--- Used to count familiars and check if the player has a Super Meat Boy or Bandage Girl
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if Isaac.GetFrameCount() % 500 ~= 0 then
        return
    end

    local familiarStatus = util.familiarStatus()

    -- Collect at least 5 familiars
    if familiarStatus.count >= 5 then
        AP_MAIN_MOD:sendLocation(Locations._5_FAMILIARS_COLLECTED_IN_ONE_RUN)
    end

    -- Make a Super Meat Boy
    if familiarStatus.meat_boy then
        AP_MAIN_MOD:sendLocation(Locations.SUPER_MEAT_BOY_MADE)
    end

    -- Make a Super Bandage Girl
    if familiarStatus.bandage_girl then
        AP_MAIN_MOD:sendLocation(Locations.SUPER_BANDAGE_GIRL_MADE)
    end

    if familiarStatus.charmed_count >= 3 then
        AP_MAIN_MOD:sendLocation(Locations._3_ENEMIES_CHARMED_AT_ONCE)
    end
end)

--- @param player EntityPlayer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    -- "Be Larger"
    if player:GetSprite().Scale.X > 1.9 then
        AP_MAIN_MOD:sendLocation(Locations.BE_LARGER_3X)
    end

    -- Have 7 or more heart containers
    if player:GetEffectiveMaxHearts() >= 14 then
        AP_MAIN_MOD:sendLocation(Locations._7_HEART_CONTAINERS)
    end

    -- Have 55 or more coins
    if player:GetNumCoins() >= 55 then
        AP_MAIN_MOD:sendLocation(Locations._55_COINS)
    end

    -- Have 4 or more soul hearts
    if player:GetSoulHearts() >= 8 then
        AP_MAIN_MOD:sendLocation(Locations._4_SOUL_HEARTS)
    end

    -- Have 20 or more blue flies at once
    if player:GetNumBlueFlies() >= 20 then
        AP_MAIN_MOD:sendLocation(Locations._20_BLUE_FLIES_AT_ONCE)
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
                AP_MAIN_MOD:sendLocation(Locations.BIBLE_USED_ON_MOM)
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
        AP_MAIN_MOD:sendLocation(Locations.BLANK_CARD_USED_WHILE_HOLDING_XIX___THE_SUN)
    end
end)

--- @param pillEffect PillEffect
--- @param player EntityPlayer
--- @param flags integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_PILL, function (_, pillEffect, player, flags)
    if pillEffect == PillEffect.PILLEFFECT_GULP then
        -- Use Gulp! 5 times in one run
        if incrementStat(StatKeys.GULP_USES_THIS_RUN) == 5 then
            AP_MAIN_MOD:sendLocation(Locations.GULP_PILL_USED_5X)
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
        AP_MAIN_MOD:sendLocation(Locations.NO_DAMAGE_FOR_TWO_FLOORS)
    end

    -- 2 stages cleared without picking up hearts
    if game:GetStagesWithoutHeartsPicked() >= 2 then
        AP_MAIN_MOD:sendLocation(Locations.NO_HEARTS_FOR_TWO_FLOORS)
    end

    -- Enter the Corpse
    local level = game:GetLevel()
    if level:GetStage() == LevelStage.STAGE4_1 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
        AP_MAIN_MOD:sendLocation(Locations.CORPSE_ENTERED)
    end
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    local game = Game()
    local roomType = game:GetRoom():GetType()

    -- Visit 10 arcades
    if not getStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_ARCADE then
        setStat(StatKeys.ARCADE_VISITED_THIS_FLOOR, true)

        if incrementStat(StatKeys.ARCADES_VISITED) == 10 then
            AP_MAIN_MOD:sendLocation(Locations.ARCADE_VISITED_10X)
        end
    end

    -- Visit 6 shops in one run (no greed mode)
    if not Game():IsGreedMode() and not getStat(StatKeys.SHOP_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_SHOP then
        setStat(StatKeys.SHOP_VISITED_THIS_FLOOR, true)

        if incrementStat(StatKeys.SHOPS_VISITED_THIS_RUN) == 6 then
            AP_MAIN_MOD:sendLocation(Locations._6_SHOPS_ENTERED_IN_ONE_RUN)
        end
    end

    local secretRoomVists = 0
    if not getStat(StatKeys.SECRET_ROOM_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_SECRET then
        secretRoomVists = incrementStat(StatKeys.SECRET_ROOM_VISITS)
        setStat(StatKeys.SECRET_ROOM_VISITED_THIS_FLOOR, true)
    end

    if not getStat(StatKeys.SUPER_SECRET_ROOM_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_SUPERSECRET then
        secretRoomVists = incrementStat(StatKeys.SECRET_ROOM_VISITS)
        setStat(StatKeys.SUPER_SECRET_ROOM_VISITED_THIS_FLOOR, true)
    end

    if not getStat(StatKeys.ULTRA_SECRET_ROOM_VISITED_THIS_FLOOR, false) and roomType == RoomType.ROOM_ULTRASECRET then
        secretRoomVists = incrementStat(StatKeys.SECRET_ROOM_VISITS)
        setStat(StatKeys.ULTRA_SECRET_ROOM_VISITED_THIS_FLOOR, true)
    end

    -- Visit 50 secret rooms
    if secretRoomVists >= 50 then
        AP_MAIN_MOD:sendLocation(Locations.SECRET_ROOM_FOUND_50X)
    end
end)

--- @param pickup EntityPickup
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PICKUP_PICKED, function (_, pickup)
    if pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
        if incrementStat(StatKeys.LIL_BATTERIES_PICKED) == 20 then
            AP_MAIN_MOD:sendLocation(Locations.LIL_BATTERIES_PICKED_UP_20X) -- Collect 20 lil batteries
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
            AP_MAIN_MOD:sendLocation(Locations.LOCKED_CHEST_OPENED_20X) -- Open 20 locked chests
        end
    elseif (chest.Variant == PickupVariant.PICKUP_MOMSCHEST) then
        AP_MAIN_MOD:sendLocation(Locations.OPEN_MOMS_CHEST) -- Open Mom's Chest
    end
end)

--- @param cardType Card
--- @param player EntityPlayer
--- @param flags integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, cardType, player, flags)
    -- 20 Cards or Runes used
    if incrementStat(StatKeys.CARDS_USED) == 20 then
        AP_MAIN_MOD:sendLocation(Locations.CARDS_OR_RUNES_USED_20X)
    end

    if cardType == Card.CARD_DEATH then
        if incrementStat(StatKeys.DEATH_CARDS_USED) == 4 then
            AP_MAIN_MOD:sendLocation(Locations.XIII___DEATH_USED_4X)
        end
    end
end)

--- When the player dies
--- @param player EntityPlayer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, player)
    -- Died in Sacrifice Room w/ Missing Poster
    if Game():GetRoom():GetType() == RoomType.ROOM_SACRIFICE then
        if util.hasTrinket(player, TrinketType.TRINKET_MISSING_POSTER) then
            AP_MAIN_MOD:sendLocation(Locations.DIED_IN_SACRIFICE_ROOM_W_MISSING_POSTER)
        end
    end

    -- Die 100 times
    if incrementStat(StatKeys.TOTAL_DEATHS) == 100 then
        AP_MAIN_MOD:sendLocation(Locations.DEATH_100X)
    end

    setStat(StatKeys.DIED_THIS_RUN, true)
end, EntityType.ENTITY_PLAYER)

--- When The Lamb dies (It's the Key!)
--- @param entity EntityNPC
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    if not getStat(StatKeys.HEARTS_COINS_BOMBS_PICKED_THIS_RUN, true) then
        AP_MAIN_MOD:sendLocation(Locations.ITS_THE_KEY)
    end
end, EntityType.ENTITY_THE_LAMB)
 
--- When Mom's Heart dies (Lazarus to Mom's Heart w/o Deaths)
--- @param entity EntityNPC
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    if not getStat(StatKeys.DIED_THIS_RUN, true) and Isaac.GetPlayer(0):GetType() == PlayerType.PLAYER_LAZARUS then
        AP_MAIN_MOD:sendLocation(Locations.MOMS_HEART_DEFEATED_AS_LAZARUS_W_NO_DEATHS)
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
        if damageFlags & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
            AP_MAIN_MOD:sendLocation(Locations.EXPLODED_SIRENS_SKULL)
        end
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
        AP_MAIN_MOD:sendLocation(Locations.SHOPKEEPERS_EXPLODED_20X)
    end
end, EntityType.ENTITY_SHOPKEEPER)

--- Tracks destroying slot machines and beggars.
--- @param entity Entity
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PRE_SLOT_KILLED, function (_, entity)
    -- Blow up Battery Bum 10 times
    if entity.Variant == 13 then
        if incrementStat(StatKeys.BATTERY_BUMS_KILLED) == 10 then
            AP_MAIN_MOD:sendLocation(Locations.BATTERY_BUM_EXPLODED_10X)
        end

    -- Blow up 30 slot machines
    elseif entity.Variant == 1 then
        if incrementStat(StatKeys.SLOT_MACHINES_KILLED) == 30 then
            AP_MAIN_MOD:sendLocation(Locations.SLOT_MACHINE_EXPLODED_30X)
        end
    end
end)

--- Tracks beggars paying out collectibles.
--- @param entity Entity
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_BEGGAR_COLLECTIBLE_PAYOUT, function (_, entity)
    -- Get 5 collectible payouts from a Battery Bum
    if entity.Variant == 13 and incrementStat(StatKeys.BATTERY_BUM_COLLECTIBLE_PAYOUTS) == 5 then
        AP_MAIN_MOD:sendLocation(Locations.BATTERY_BUM_PAYOUT_5X)
    end
end)

--- Tracks playing shell games and slot machines.
--- @param entity Entity
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_SLOT_GAME_END, function (_, entity)
    local isShellGame = entity.Variant == 6 or entity.Variant == 15

    -- Play shell game 100 times
    if isShellGame and incrementStat(StatKeys.SHELL_GAME_PLAYS) == 100 then
        AP_MAIN_MOD:sendLocation(Locations.SHELL_GAME_PLAYED_100X)

    -- Donate blood 30 times
    elseif entity.Variant == 2 and incrementStat(StatKeys.BLOOD_DONATIONS) == 30 then
        AP_MAIN_MOD:sendLocation(Locations.BLOOD_DONATED_30X)
    end

    -- Rescuing tainted character from Home closet
    if entity.Variant == 14 then
        local taintedCharacterName = util.getTaintedCharacterName()
        AP_MAIN_MOD:sendLocation(taintedCharacterName .. " Unlock")
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
            AP_MAIN_MOD:sendLocation(Locations.ANGEL_ITEMS_TAKEN_10X)
        elseif taken == 25 then
            AP_MAIN_MOD:sendLocation(Locations.ANGEL_ITEMS_TAKEN_25X)
        end
    end

    -- Pick up 20, 25, 30 devil items
    if roomType == RoomType.ROOM_DEVIL then
        local taken = incrementStat(StatKeys.DEVIL_ITEMS_TAKEN)
        
        if taken == 20 then
            AP_MAIN_MOD:sendLocation(Locations.DEVIL_DEALS_TAKEN_20X)
        elseif taken == 25 then
            AP_MAIN_MOD:sendLocation(Locations.DEVIL_DEALS_TAKEN_25X)
        elseif taken == 30 then
            AP_MAIN_MOD:sendLocation(Locations.DEVIL_DEALS_TAKEN_30X)
        end

        -- Pick up 3 devil items in one run
        if incrementStat(StatKeys.DEVIL_ITEMS_TAKEN_THIS_RUN) == 3 then
            AP_MAIN_MOD:sendLocation(Locations.DEVIL_DEALS_TAKEN_3X_IN_ONE_RUN)
        end
    end
end)

--- Determines if the player has fulfilled the "collect 10 tears up items or pills" condition, and sends the location
--- @param player EntityPlayer
local function tryTearsUpCollectionLocation(player)
    -- Collect at least 10 tears up items or pills
    local tearsItems = util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.STARS)
    if tearsItems + getStat(StatKeys.TEARS_UP_PILLS_THIS_RUN, 0) >= 10 then
        AP_MAIN_MOD:sendLocation(Locations.TEARS_UP_COLLECTED_10X)
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
            AP_MAIN_MOD:sendLocation(Locations.RUBBER_CEMENT_COLLECTED_5X)
        end
    end

    -- Collected 10 Blood Clots
    if item.ID == CollectibleType.COLLECTIBLE_BLOOD_CLOT then
        if incrementStat(StatKeys.BLOOD_CLOTS_COLLECTED) == 10 then
            AP_MAIN_MOD:sendLocation(Locations.BLOOD_CLOT_COLLECTED_10X)
        end
    end

   -- Own at least 50 collectibles
    if player:GetCollectibleCount() >= 50 then
        AP_MAIN_MOD:sendLocation(Locations.ITEMS_OWNED_AT_ONCE_50X)
    end

    -- Collect Key Piece 1 and 2
    if util.hasAllCollectibles(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.KEY_PIECES) then
        AP_MAIN_MOD:sendLocation(Locations.KEY_PIECES_COLLECTED)
    end

    -- Collect Battery, 9 Volt, Car Battery
    if util.hasAllCollectibles(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.SIMPLE_BATTERIES) then
        AP_MAIN_MOD:sendLocation(Locations.COLLECTED_BATTERY_9_VOLT_AND_CAR_BATTERY)
    end

    -- Collect Broken Watch and Stop Watch
    if util.hasAllCollectibles(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.WATCH) then
        AP_MAIN_MOD:sendLocation(Locations.STOP_WATCH_AND_BROKEN_STOP_WATCH_COLLECTED)
    end

    -- Collect at least 2 battery items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.BATTERY) >= 2 then
        AP_MAIN_MOD:sendLocation(Locations._2_BATTERY_ITEMS_COLLECTED)
    end

    -- Collect at least 2 dead items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.DEAD) >= 2 then
        AP_MAIN_MOD:sendLocation(Locations._2_DEAD_ITEMS_COLLECTED)
    end

    -- Collect at least 3 mom items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.MOM) >= 2 then
        AP_MAIN_MOD:sendLocation(Locations._3_MOM_ITEMS_COLLECTED)
    end

    -- Collect at least 2 technology items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.TECH) >= 2 then
        AP_MAIN_MOD:sendLocation(Locations._2_TECHNOLOGY_ITEMS_COLLECTED)
    end

    -- Collect at least 3 celestial items
    if util.countCollectibleTypes(player, AP_MAIN_MOD.COLLECTIBLE_TAGS_DATA.STARS) >= 3 then
        AP_MAIN_MOD:sendLocation(Locations._3_CELESTIAL_ITEMS_COLLECTED)
    end

    tryTearsUpCollectionLocation(player)
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
            AP_MAIN_MOD:sendLocation(Locations.WIN_STREAK_3X)
        end

        -- 5 Win Streak
        if wins >= 5 then
            AP_MAIN_MOD:sendLocation(Locations.WIN_STREAK_5X)
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
    if oldState == nil then
        return -- We likely entered a new room, so we shouldn't count this
    end

    local type = gridEntity:GetType()
    local variant = gridEntity:GetVariant()

    if type == GridEntityType.GRID_POOP and gridEntity.State == GridState.POOP_DESTROYED then
        -- Destroy 5 rainbow poops
        if variant == 4 and incrementStat(StatKeys.RAINBOW_POOPS_DESTROYED) == 5 then
            AP_MAIN_MOD:sendLocation(Locations.RAINBOW_POOP_DESTROYED_5X)
        end

        -- Destroy 100 poops
        if incrementStat(StatKeys.POOPS_DESTROYED) == 100 then
            AP_MAIN_MOD:sendLocation(Locations.POOP_DESTROYED_100X)
        end
    elseif GridRockTypes[type] and gridEntity.State == GridState.ROCK_DESTROYED then
        local rocksDestroyed = incrementStat(StatKeys.ROCKS_DESTROYED)

        if rocksDestroyed == 100 then -- Destroy 100 rocks
            AP_MAIN_MOD:sendLocation(Locations.ROCK_DESTROYED_100X)
        elseif rocksDestroyed == 500 then -- Destroy 500 rocks
            AP_MAIN_MOD:sendLocation(Locations.ROCK_DESTROYED_500X)
        end

        if type == GridEntityType.GRID_ROCKT or type == GridEntityType.GRID_ROCK_SS then
            local tintedRocksDestroyed = incrementStat(StatKeys.TINTED_ROCKS_DESTROYED)

            if tintedRocksDestroyed == 10 then -- Destroy 10 tinted rocks
                AP_MAIN_MOD:sendLocation(Locations.TINTED_ROCK_DESTROYED_10X)
            elseif tintedRocksDestroyed == 100 then -- Destroy 100 tinted rocks
                AP_MAIN_MOD:sendLocation(Locations.TINTED_ROCK_DESTROYED_100X)
            end
        end
    end
end)

--- Used to track how many times the player has slept in a bed.
AP_MAIN_MOD:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_BED_SLEEP, function (_)
    local sleeps = incrementStat(StatKeys.BEDS_SLEPT_IN)

    print("EEUGH")

    if sleeps == 1 then
        AP_MAIN_MOD:sendLocation(Locations.BED_SLEPT_IN)
    elseif sleeps == 10 then
        AP_MAIN_MOD:sendLocation(Locations.BED_SLEPT_IN_10X)
    end
end)