local function getItemForCurrentRoom(seed)
    local game = Game()
    local level = game:GetLevel()
    local room = level:GetCurrentRoom()
    local itemPool = game:GetItemPool()
    local poolForRoom = itemPool:GetPoolForRoom(room:GetType(), seed)
    return itemPool:GetCollectible(poolForRoom, false, seed, CollectibleType.COLLECTIBLE_BREAKFAST)
end

--- @param entityType EntityType
--- @param variant integer
--- @param collectibleType CollectibleType
--- @param position Vector
--- @param velocity Vector
--- @param spawnerEntity Entity|nil
--- @param seed integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, entityType, variant, collectibleType, position, velocity, spawnerEntity, seed)
    if entityType ~= EntityType.ENTITY_PICKUP or variant ~= PickupVariant.PICKUP_COLLECTIBLE then
        return
    end

    -- In case collectibleType is ever nil
    if collectibleType == nil then
        AP_MAIN_MOD:Error("CollectibleType is nil")
        return
    end

    -- Get the code for the collectible that's trying to spawn
    local code = AP_MAIN_MOD.ITEMS_DATA.COLLECTIBLE_ID_TO_CODE[collectibleType]

    -- Error catching
    if code == nil then
        AP_MAIN_MOD:Error("Code for collectible '" .. tostring(collectibleType) .. "' is nil")
        return
    end

    -- This item is unlocked, so we don't care
    if AP_MAIN_MOD:checkUnlocked(code) then
        return
    end

    -- Item is locked, replace with a random collectible from the current room's pool
    collectibleType = getItemForCurrentRoom(seed)

    return {entityType, variant, collectibleType, seed}
end)