local util = Archipelago.util

local EntityItemName = {
    LUCKY_PENNIES = "Lucky Pennies",
    SPECIAL_HANGING_SHOPKEEPERS = "Special Hanging Shopkeepers",
    SPECIAL_SHOPKEEPERS = "Special Shopkeepers",
    SUPER_SPECIAL_ROCKS = "Super Special Rocks",
    ROTTEN_HEART = "Rotten Heart",
    SCARED_HEART = "Scared Heart",
    CORRUPTED_DATA = "Corrupted Data",
    MEGA_CHEST = "Mega Chest",
    GOLD_PILL = "Gold Pill",
    BLACK_SACK = "Black Sack",
    CHARMING_POOP = "Charming Poop",
    HORSE_PILL = "Horse Pill",
    CRANE_GAME = "Crane Game",
    HELL_GAME = "Hell Game",
    WOODEN_CHEST = "Wooden Chest",
    HAUNTED_CHEST = "Haunted Chest",
    FOOLS_GOLD = "Fool's Gold",
    GOLDEN_PENNY = "Golden Penny",
    ROTTEN_BEGGAR = "Rotten Beggar",
    GOLDEN_BATTERY = "Golden Battery",
    CONFESSIONAL = "Confessional",
    GOLDEN_TRINKET = "Golden Trinket",
    STICKY_NICKELS = "Sticky Nickels",
    CHARGED_KEY = "Charged Key",
    GOLD_BOMB = "Gold Bomb",
    GOLD_HEART = "Gold Heart",
    HALF_SOUL_HEART = "Half Soul Heart",
    BONE_HEART = "Bone Heart"
}

local SlotVariant = {
    SLOT_MACHINE = 1,
    BLOOD_DONATION_MACHINE = 2,
    FORTUNE_TELLING_MACHINE = 3,
    BEGGAR = 4,
    DEVIL_BEGGAR = 5,
    SHELL_GAME = 6,
    KEY_MASTER = 7,
    DONATION_MACHINE = 8,
    BOMB_BUM = 9,
    SHOP_RESTOCK_MACHINE = 10,
    GREED_DONATION_MACHINE = 11,
    MOMS_DRESSING_TABLE = 12,
    BATTERY_BUM = 13,
    HOME_CLOSET_PLAYER = 14,
    HELL_GAME = 15,
    CRANE_GAME = 16,
    CONFESSIONAL = 17,
    ROTTEN_BEGGAR = 18,
}

local ShopkeeperVariant = {
    SHOPKEEPER = 0,
    SECRET_ROOM_KEEPER = 1,
    ERROR_KEEPER = 2,
    SPECIAL_SHOPKEEPER = 3,
    SPECIAL_SECRET_ROOM_KEEPER = 4
}

--- Call to receive replacement entity data for the given passed entity data
--- If nil, then the repalcement did not occur
--- @param type EntityType
--- @param variant integer
--- @param subType integer
local function replaceEntity(type, variant, subType)
    -- It Lives!
    if type == EntityType.ENTITY_MOMS_HEART and variant == 1 and not Archipelago:checkUnlockedByName("It Lives!") then
        return {type, 0, 0}
    end

    -- Angels (Check for variant 0 as 1 is 'Fallen' angels)
    if variant == 0 and not Archipelago:checkUnlockedByName("Angels") then
        if type == EntityType.ENTITY_GABRIEL or type == EntityType.ENTITY_URIEL then
            return {EntityType.ENTITY_FLY, variant, 0}
        end
    end

    if type == EntityType.ENTITY_PICKUP then
        -- Coins
        if variant == PickupVariant.PICKUP_COIN then
            -- Golden Penny
            if subType == CoinSubType.COIN_GOLDEN and not Archipelago:checkUnlockedByName(EntityItemName.GOLDEN_PENNY) then
                return {type, variant, CoinSubType.COIN_PENNY}
            end

            -- Lucky Penny
            if subType == CoinSubType.COIN_LUCKYPENNY and not Archipelago:checkUnlockedByName(EntityItemName.LUCKY_PENNIES) then
                return {type, variant, CoinSubType.COIN_PENNY}
            end

            -- Sticky Nickel
            if subType == CoinSubType.COIN_STICKYNICKEL and not Archipelago:checkUnlockedByName(EntityItemName.STICKY_NICKELS) then
                return {type, variant, CoinSubType.COIN_PENNY}
            end
        end

        -- Hearts
        if variant == PickupVariant.PICKUP_HEART then
            -- Rotten Heart
            if subType == HeartSubType.HEART_ROTTEN and not Archipelago:checkUnlockedByName(EntityItemName.ROTTEN_HEART) then
                return {type, variant, HeartSubType.HEART_FULL}
            end

            -- Scared Heart
            if subType == HeartSubType.HEART_SCARED and not Archipelago:checkUnlockedByName(EntityItemName.SCARED_HEART) then
                return {type, variant, HeartSubType.HEART_HALF}
            end

            -- Half Soul Heart
            if subType == HeartSubType.HEART_HALF_SOUL and not Archipelago:checkUnlockedByName(EntityItemName.HALF_SOUL_HEART) then
                return {type, variant, HeartSubType.HEART_HALF}
            end

            -- Gold Heart
            if subType == HeartSubType.HEART_GOLDEN and not Archipelago:checkUnlockedByName(EntityItemName.GOLD_HEART) then
                return {type, variant, HeartSubType.HEART_FULL}
            end

            -- Bone Heart
            if subType == HeartSubType.HEART_BONE and not Archipelago:checkUnlockedByName(EntityItemName.BONE_HEART) then
                return {type, variant, HeartSubType.HEART_FULL}
            end
        end

        -- Gold Bomb, Gold Troll Bomb
        if variant == PickupVariant.PICKUP_BOMB then
            if not Archipelago:checkUnlockedByName(EntityItemName.GOLD_BOMB) then
                if subType == BombSubType.BOMB_GOLDEN then
                    return {type, variant, BombSubType.BOMB_NORMAL}
                end

                if subType == BombSubType.BOMB_GOLDENTROLL then
                    return {type, variant, BombSubType.BOMB_TROLL}
                end
            end
        end

        -- Charged Key
        if variant == PickupVariant.PICKUP_KEY and subType == KeySubType.KEY_CHARGED and not Archipelago:checkUnlockedByName(EntityItemName.CHARGED_KEY) then
            return {type, variant, KeySubType.KEY_NORMAL}
        end

        -- Golden Trinkets
        if variant == PickupVariant.PICKUP_TRINKET and subType & TrinketType.TRINKET_GOLDEN_FLAG > 0 and not Archipelago:checkUnlockedByName(EntityItemName.GOLDEN_TRINKET) then
            return {type, variant, subType & ~TrinketType.TRINKET_GOLDEN_FLAG}
        end

        -- Pills
        if variant == PickupVariant.PICKUP_PILL then
            local isGiant = subType & PillColor.PILL_GIANT_FLAG > 0
            local color = subType

            -- Horse Pills
            if isGiant and not Archipelago:checkUnlockedByName(EntityItemName.HORSE_PILL) then
                subType = subType & ~PillColor.PILL_GIANT_FLAG
                isGiant = false
            end

            -- Gold Pills
            if subType == PillColor.PILL_GOLD and not Archipelago:checkUnlockedByName(EntityItemName.GOLD_PILL) then
                if isGiant then -- In case the pill was giant
                    color = color & PillColor.PILL_GIANT_FLAG
                else
                    color = PillColor.PILL_BLACK_YELLOW
                end
            end

            return {type, variant, color}
        end

        -- Black Sack
        if variant == PickupVariant.PICKUP_GRAB_BAG then
            if subType == SackSubType.SACK_BLACK and not Archipelago:checkUnlockedByName(EntityItemName.BLACK_SACK) then
                return {type, variant, SackSubType.SACK_NORMAL}
            end
        end

        -- Haunted Chest
        if variant == PickupVariant.PICKUP_HAUNTEDCHEST and not Archipelago:checkUnlockedByName(EntityItemName.HAUNTED_CHEST) then
            return {type, PickupVariant.PICKUP_CHEST, 0}
        end

        -- Mega Chest
        if variant == PickupVariant.PICKUP_MEGACHEST and not Archipelago:checkUnlockedByName(EntityItemName.MEGA_CHEST) then
            return {type, PickupVariant.PICKUP_LOCKEDCHEST, 0}
        end

        -- Wooden Chest
        if variant == PickupVariant.PICKUP_WOODENCHEST and not Archipelago:checkUnlockedByName(EntityItemName.WOODEN_CHEST) then
            return {type, PickupVariant.PICKUP_CHEST, 0}
        end

        -- Golden Battery
        if variant == PickupVariant.PICKUP_LIL_BATTERY and subType == BatterySubType.BATTERY_GOLDEN and not Archipelago:checkUnlockedByName(EntityItemName.GOLDEN_BATTERY) then
            return {type, variant, BatterySubType.BATTERY_NORMAL}
        end
    end

    if type == EntityType.ENTITY_SLOT then
        -- Hell Game
        if variant == SlotVariant.HELL_GAME and not Archipelago:checkUnlockedByName(EntityItemName.ROTTEN_BEGGAR) then
            return {type, SlotVariant.SHELL_GAME, subType}
        end

        -- Rotten Beggar
        if variant == SlotVariant.ROTTEN_BEGGAR and not Archipelago:checkUnlockedByName(EntityItemName.ROTTEN_BEGGAR) then
            return {type, SlotVariant.BEGGAR, subType}
        end

        -- Crane Game
        if variant == SlotVariant.CRANE_GAME and not Archipelago:checkUnlockedByName(EntityItemName.CRANE_GAME) then
            return {type, SlotVariant.SLOT_MACHINE, subType}
        end

        -- Confessional
        if variant == SlotVariant.CONFESSIONAL and not Archipelago:checkUnlockedByName(EntityItemName.CONFESSIONAL) then
            return {type, SlotVariant.BLOOD_DONATION_MACHINE, subType}
        end
    end

    if type == EntityType.ENTITY_SHOPKEEPER then
        -- Special Shopkeepers
        if variant == ShopkeeperVariant.SPECIAL_SHOPKEEPER and not Archipelago:checkUnlockedByName(EntityItemName.SPECIAL_SHOPKEEPERS) then
            return {type, ShopkeeperVariant.SHOPKEEPER, subType}
        end

        -- Special Hanging Shopkeepers
        if variant == ShopkeeperVariant.SPECIAL_SECRET_ROOM_KEEPER and not Archipelago:checkUnlockedByName(EntityItemName.SPECIAL_SHOPKEEPERS) then
            return {type, ShopkeeperVariant.SECRET_ROOM_KEEPER, subType}
        end
    end

    if not Archipelago:checkUnlockedByName("Everything is Terrible!!!") then
        -- TODO: Remove champion effect on enemies (no way to tell if this is an enemy yet)

        -- Bulb to Fly
        if type == EntityType.ENTITY_SUCKER and variant == 5 then
            return {EntityType.ENTITY_FLY, 0, 0}

        -- Micro Battery to Battery
        elseif type == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_LIL_BATTERY and subType == BatterySubType.BATTERY_MICRO then
            return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL}
        end
    end

    -- The Gate is Open! enemies
    if not Archipelago:checkUnlockedByName("The gate is open!") then
        local rng = RNG(Archipelago.room():GetSpawnSeed(), 35)
        local level = Archipelago.level()

        -- Blister
        if type == EntityType.ENTITY_BLISTER then
            if rng:RandomFloat() < 0.7 then -- 70% chance for Ticking Spider
                return {EntityType.ENTITY_TICKING_SPIDER, 0, 0}
            else -- 30% chance for Keeper
                return {EntityType.ENTITY_KEEPER, 0, 0}
            end

        -- Mushroom
        elseif type == EntityType.ENTITY_MUSHROOM then
            if rng:RandomFloat() < 0.8 then -- 80% chance for Host
                return {EntityType.ENTITY_HOST, 0, 0}
            else -- 20% chance for Red Host
                return {EntityType.ENTITY_HOST, 1, 0}
            end
        
        -- Ministro
        elseif type == EntityType.ENTITY_MINISTRO then
            if level:GetStageType() == StageType.STAGETYPE_WOTL then -- Trite for WOTL levels
                return {EntityType.ENTITY_HOPPER, 1, 0}
            else -- Hopper for all others
                return {EntityType.ENTITY_HOPPER, 0, 0}
            end
        
        -- Nerve Ending 2 (Always becomes Nerve Ending)
        elseif type == EntityType.ENTITY_NERVE_ENDING and variant == 1 then
            return {EntityType.ENTITY_NERVE_ENDING, 0, 0}
        
        -- Poison Mind (Always becomes Brain)
        elseif type == EntityType.ENTITY_POISON_MIND then
            return {EntityType.ENTITY_BRAIN, 0, 0}

        -- Stoney
        elseif type == EntityType.ENTITY_STONEY then
            if level:GetStage() >= LevelStage.STAGE3_1 then -- Pale Fatty on Depths+
                return {EntityType.ENTITY_FATTY, 1, 0}
            else -- Fatty everywhere else
                return {EntityType.ENTITY_FATTY, 0, 0}
            end

        -- The Thing
        elseif type == EntityType.ENTITY_THE_THING then
            if level:GetStage() >= LevelStage.STAGE3_1 then
                local r = rng:RandomFloat()

                if r > 0.66 then -- 33% chance for Wall Creep
                    return {EntityType.ENTITY_WALL_CREEP, 0, 0}
                elseif r > 0.33 then -- 33% chance for Blind Creep
                    return {EntityType.ENTITY_BLIND_CREEP, 0, 0}
                else -- 33% chance for Rage Creep
                    return {EntityType.ENTITY_RAGE_CREEP, 0, 0}
                end
            else -- Earlier stages cannot have Rage Creep
                if rng:RandomFloat() < 0.5 then -- 50% chance for Wall Creep
                    return {EntityType.ENTITY_WALL_CREEP, 0, 0}
                else -- 50% chance for Blind Creep
                    return {EntityType.ENTITY_BLIND_CREEP, 0, 0}
                end
            end
        end
    end

    return nil
end

-- Replace entities that are freshly spawned, or exist in the room we return to
Archipelago:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, type, variant, subType, position, velocity, spawnerEntity, seed)
    return replaceEntity(type, variant, subType)
end)

-- Replace entities that are a part of the layout
Archipelago:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function (_, type, variant, subType, gridIndex, seed)
    return replaceEntity(type, variant, subType)
end)

--- Used to do basically the same thing as the previous two, but for room drops (I guess???)
--- @param pickup EntityPickup
--- @param variant PickupVariant
--- @param subType integer
Archipelago:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, function (_, pickup, variant, subType)
    local newValues = replaceEntity(EntityType.ENTITY_PICKUP, variant, subType)

    if not newValues then
        return
    end

    return {newValues[2], newValues[3]}
end)