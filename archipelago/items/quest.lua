local util = Archipelago.util

--- Returns a random collectible ID for the given room's pool.
--- @param seed integer
--- @return CollectibleType
local function getItemForCurrentRoom(seed)
    local game = Game()
    local level = game:GetLevel()
    local room = level:GetCurrentRoom()
    local itemPool = game:GetItemPool()
    local poolForRoom = itemPool:GetPoolForRoom(room:GetType(), seed)
    return itemPool:GetCollectible(poolForRoom, false, seed, CollectibleType.COLLECTIBLE_BREAKFAST)
end

--- 'true' if Inner Child should be replaced by a rescuable Isaac
--- @return boolean
local function shouldReplaceInnerChild()
    local level = Game():GetLevel()

    if level:GetStage() ~= LevelStage.STAGE8 then -- Must be in Home
        return false
    end

    if level:GetCurrentRoomIndex() ~= 94 then -- Must be in the closet (this is a very specific room index)
        return false
    end

    if util.isCharacterTainted() then -- Character must not be tainted
        return false
    end

    local locationName = util.getTaintedCharacterName() .. " Unlock"
    if Archipelago:checkLocationSent(Archipelago.LOCATIONS_DATA[locationName]) then -- Location must not be found already
        return false
    end

    return true
end

--- @param entityType EntityType
--- @param variant integer
--- @param collectibleType CollectibleType
--- @param position Vector
--- @param velocity Vector
--- @param spawnerEntity Entity|nil
--- @param seed integer
Archipelago:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, entityType, variant, collectibleType, position, velocity, spawnerEntity, seed)
    if entityType ~= EntityType.ENTITY_PICKUP or variant ~= PickupVariant.PICKUP_COLLECTIBLE then
        return
    end

    -- This is a 'random' collectible, so other callbacks should handle it
    if collectibleType == CollectibleType.COLLECTIBLE_NULL then
        return
    end

    -- In case collectibleType is ever nil
    if collectibleType == nil then
        util.Error("CollectibleType is nil")
        return
    end

    -- It's inner child, it may need to be replaced with a rescuable Isaac
    if collectibleType == CollectibleType.COLLECTIBLE_INNER_CHILD then
        if shouldReplaceInnerChild() then
            return {EntityType.ENTITY_SLOT, 14, 0, seed} -- Replace with rescuable Isaac!
        end
    end

    -- Get the code for the collectible that's trying to spawn
    local code = Archipelago.ITEMS_DATA.COLLECTIBLE_ID_TO_CODE[collectibleType]

    -- Error catching
    if code == nil then
        util.Error("Code for collectible '" .. tostring(collectibleType) .. "' is nil")
        return
    end

    -- This item is unlocked, so we don't care
    if Archipelago:checkUnlocked(code) then
        return
    end

    -- Item is locked, replace with a random collectible from the current room's pool
    collectibleType = getItemForCurrentRoom(seed)

    return {entityType, variant, collectibleType, seed}
end)