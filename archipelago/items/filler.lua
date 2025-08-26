local util = Archipelago.util

--- Spawns a given number of pickups around player 0.
--- @param count integer
--- @param pickupVariant PickupVariant
--- @param subTypeSelector fun(rng: RNG): integer
local function spawnGoodies(count, pickupVariant, subTypeSelector)
    local rng = util.getRNG()
    local isaacPos = Isaac.GetPlayer(0).Position

    for i = 0, count, 1 do
        local pos = Isaac.GetFreeNearPosition(isaacPos, 1)
        Archipelago.game:Spawn(EntityType.ENTITY_PICKUP, pickupVariant, pos, Vector.Zero, nil, subTypeSelector(rng), rng:RandomInt(65535) + 1)
    end
end

--- Handles spawning filler items.
--- @param itemName string
local function handleFiller(itemName)
    -- "Active Recharge" - Charges all held active items
    if itemName == "Active Recharge" then
        util.onAllPlayers(function (player)
            ---@diagnostic disable-next-line: param-type-mismatch
            player:FullCharge(-1, true) -- -1 is allowed here, to mean "all slots"
        end)

    -- "Temporary Shield" - Uses Algiz
    elseif itemName == "Temporary Shield" then
        util.onAllPlayers(function (player)
            player:UseCard(Card.RUNE_ALGIZ, UseFlag.USE_NOANIM)
        end)
    
    -- "Three Coins" - Spawns three random coins near the player
    elseif itemName == "Three Coins" then
        spawnGoodies(3, PickupVariant.PICKUP_COIN, function (_) return 0 end)
    
    --- "Three Cards" - Spawns three random cards near the player
    elseif itemName == "Three Cards" then
        spawnGoodies(3, PickupVariant.PICKUP_TAROTCARD, function (rng)
            return Archipelago.itemPool:GetCard(rng:GetSeed(), true, false, false)
        end)

    --- "Three Runes" - Spawns three random runes near the player
    elseif itemName == "Three Cards" then
        spawnGoodies(3, PickupVariant.PICKUP_TAROTCARD, function (rng)
            return Archipelago.itemPool:GetCard(rng:GetSeed(), false, true, true)
        end)

    -- "Three Pills" - Spawns three random pills near the player.
    elseif itemName == "Three Pills" then
        spawnGoodies(3, PickupVariant.PICKUP_PILL, function (_) return 0 end)

    -- "Three Hearts" - Spawns three random hearts near the player
    elseif itemName == "Three Hearts" then
        spawnGoodies(3, PickupVariant.PICKUP_HEART, function (_) return 0 end)

    -- "Three Bombs" - Spawns three random bombs near the player
    elseif itemName == "Three Hearts" then
        spawnGoodies(3, PickupVariant.PICKUP_BOMB, function (_) return 0 end)

    -- "Three Keys" - Spawns three random keys near the player
    elseif itemName == "Three Keys" then
        spawnGoodies(3, PickupVariant.PICKUP_KEY, function (_) return 0 end)
    end
end

--- Handles spawning trap items.
--- @param itemName string
local function handleTrap(itemName)
    -- "Fool Trap" - Uses The Fool
    if itemName == "Fool Trap" then
        Isaac.GetPlayer(0):UseCard(Card.CARD_FOOL, UseFlag.USE_NOANIM)

    -- "High Priestess Trap" - Uses High Priestess
    elseif itemName == "High Priestess Trap" then
        util.onAllPlayers(function (player)
            player:UseCard(Card.CARD_HIGH_PRIESTESS, UseFlag.USE_NOANIM)
        end)

    -- "Tower Trap" - Uses The Tower
    elseif itemName == "Tower Trap" then
        util.onAllPlayers(function (player)
            player:UseCard(Card.CARD_TOWER, UseFlag.USE_NOANIM)
        end)

    -- "Emperor Trap" - Uses The Emperor
    elseif itemName == "Emperor Trap" then
        Isaac.GetPlayer(0):UseCard(Card.CARD_EMPEROR, UseFlag.USE_NOANIM)

    -- "Damocles Trap" - Uses Damocles
    elseif itemName == "Damocles Trap" then
        util.onAllPlayers(function (player)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DAMOCLES, UseFlag.USE_NOANIM)
        end)

    -- "Chariot? Trap" - Uses The Chariot?
    elseif itemName == "Chariot? Trap" then
        util.onAllPlayers(function (player)
            player:UseCard(Card.CARD_REVERSE_CHARIOT, UseFlag.USE_NOANIM)
        end)

    -- "Stars? Trap" - Uses The Stars?
    elseif itemName == "Stars? Trap" then
        util.onAllPlayers(function (player)
            player:UseCard(Card.CARD_REVERSE_STARS, UseFlag.USE_NOANIM)
        end)

    -- "Forget Me Now Trap" - Uses Forget Me Now
    elseif itemName == "Forget Me Now Trap" then
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM)

    -- "TM Trainer Trap" - Gives TM Trainer
    elseif itemName == "TM Trainer Trap" then
        Isaac.GetPlayer(0):AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)

    -- "Clicker Trap" - Uses Clicker
    elseif itemName == "Clicker Trap" then
        util.onAllPlayers(function (player)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_CLICKER, UseFlag.USE_NOANIM)
        end)

    -- "Run" - Uses High Priestess?
    elseif itemName == "Run" then
        util.onAllPlayers(function (player)
            player:UseCard(Card.CARD_REVERSE_HIGH_PRIESTESS, UseFlag.USE_NOANIM)
        end)

    -- "Wheel of Fortune? Trap" - Uses Wheel of Fortune?
    elseif itemName == "Wheel of Fortune? Trap" then
        util.onAllPlayers(function (player)
            player:UseCard(Card.CARD_WHEEL_OF_FORTUNE, UseFlag.USE_NOANIM)
        end)
    end
end

--- Handles spawning filler items.
--- @param itemName string
--- @param playerName string
--- @param locationName string
--- @param isTrap boolean
Archipelago:AddCallback(Archipelago.Callbacks.MC_ARCHIPELAGO_ITEM_RECEIVED, function(_, itemName, playerName, locationName, isTrap)
    if not isTrap then
        handleFiller(itemName)
    else
        handleTrap(itemName)
    end
end)