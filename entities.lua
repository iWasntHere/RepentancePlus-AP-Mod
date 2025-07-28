local entityStateKeys = {
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

    STICKY_NICKEL = "Sticky Nickels",
    CHARGED_KEY = "Charged Key",
    GOLDEN_BOMB = "Golden Bombs",
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

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, type, variant, subType, position, velocity, spawnerEntity, seed)
    if type == EntityType.ENTITY_PICKUP then
        -- Coins
        if variant == PickupVariant.PICKUP_COIN then
            -- Golden Penny
            if subType == CoinSubType.COIN_GOLDEN and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.GOLDEN_PENNY) then
                return {type, variant, CoinSubType.COIN_PENNY}
            end

            -- Lucky Penny
            if subType == CoinSubType.COIN_LUCKYPENNY and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.LUCKY_PENNIES) then
                return {type, variant, CoinSubType.COIN_PENNY}
            end
        end

        -- Hearts
        if variant == PickupVariant.PICKUP_HEART then
            -- Rotten Heart
            if subType == HeartSubType.HEART_ROTTEN and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.ROTTEN_HEART) then
                return {type, variant, HeartSubType.HEART_FULL}
            end

            -- Scared Heart
            if subType == HeartSubType.HEART_SCARED and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.SCARED_HEART) then
                return {type, variant, HeartSubType.HEART_HALF}
            end
        end

        -- Golden Trinkets
        if variant == PickupVariant.PICKUP_TRINKET and subType & TrinketType.TRINKET_GOLDEN_FLAG > 0 and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.GOLDEN_TRINKET) then
            return {type, variant, subType & ~TrinketType.TRINKET_GOLDEN_FLAG}
        end

        -- Pills
        if variant == PickupVariant.PICKUP_PILL then
            local isGiant = subType & PillColor.PILL_GIANT_FLAG > 0
            local color = subType

            -- Horse Pills
            if isGiant and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.HORSE_PILL) then
                subType = subType & ~PillColor.PILL_GIANT_FLAG
                isGiant = false
            end

            -- Gold Pills
            if subType == PillColor.PILL_GOLD and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.GOLD_PILL) then
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
            if subType == SackSubType.SACK_BLACK and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.BLACK_SACK) then
                return {type, variant, SackSubType.SACK_NORMAL}
            end
        end

        -- Haunted Chest
        if variant == PickupVariant.PICKUP_HAUNTEDCHEST and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.HAUNTED_CHEST) then
            return {type, PickupVariant.PICKUP_CHEST, 0}
        end

        -- Mega Chest
        if variant == PickupVariant.PICKUP_MEGACHEST and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.MEGA_CHEST) then
            return {type, PickupVariant.PICKUP_LOCKEDCHEST, 0}
        end

        -- Wooden Chest
        if variant == PickupVariant.PICKUP_WOODENCHEST and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.WOODEN_CHEST) then
            return {type, PickupVariant.PICKUP_CHEST, 0}
        end

        -- Golden Battery
        if variant == PickupVariant.PICKUP_LIL_BATTERY and subType == BatterySubType.BATTERY_GOLDEN and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.GOLDEN_BATTERY) then
            return {type, variant, BatterySubType.BATTERY_NORMAL}
        end
    end

    if type == EntityType.ENTITY_SLOT then
        -- Hell Game
        if variant == SlotVariant.HELL_GAME and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.ROTTEN_BEGGAR) then
            return {type, SlotVariant.SHELL_GAME, subType}
        end

        -- Rotten Beggar
        if variant == SlotVariant.ROTTEN_BEGGAR and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.ROTTEN_BEGGAR) then
            return {type, SlotVariant.BEGGAR, subType}
        end

        -- Crane Game
        if variant == SlotVariant.CRANE_GAME and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.CRANE_GAME) then
            return {type, SlotVariant.BEGGAR, subType}
        end

        -- Confessional
        if variant == SlotVariant.CONFESSIONAL and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.CONFESSIONAL) then
            return {type, SlotVariant.BLOOD_DONATION_MACHINE, subType}
        end
    end

    if type == EntityType.ENTITY_SHOPKEEPER then
        -- Special Shopkeepers
        if variant == ShopkeeperVariant.SPECIAL_SHOPKEEPER and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.SPECIAL_SHOPKEEPERS) then
            return {type, ShopkeeperVariant.SHOPKEEPER, subType}
        end

        -- Special Hanging Shopkeepers
        if variant == ShopkeeperVariant.SPECIAL_SECRET_ROOM_KEEPER and not AP_MAIN_MOD:checkUnlocked(entityStateKeys.SPECIAL_SHOPKEEPERS) then
            return {type, ShopkeeperVariant.SECRET_ROOM_KEEPER, subType}
        end
    end

    return nil
end)