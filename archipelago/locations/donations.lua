local util = require("archipelago.util")
local beggarType = Isaac.GetEntityTypeByName("Archipelago Beggar")
local beggarVariant = Isaac.GetEntityVariantByName("Archipelago Beggar")
local sfx = SFXManager()
local Locations = AP_MAIN_MOD.LOCATIONS_DATA.LOCATIONS

local SlotVariant = {
    DONATION_MACHINE = 8,
    GREED_DONATION_MACHINE = 11
}

--- Awards the next location for donating on the current game mode.
local function awardDonationCheck()
    local isGreedMode = Game():IsGreedMode()
    local key = "donations"
    local locationCode = Locations.SHOP_DONATION

    if isGreedMode then
        key = "greed_donations"
        locationCode = Locations.GREED_DONATION
    end

    local donations = AP_SUPP_MOD:LoadKey(key, 0)
    donations = donations + 1
    AP_MAIN_MOD:sendLocation(locationCode + donations)
    AP_SUPP_MOD:SaveKey(key, donations)

    if not isGreedMode then
        -- TODO: Give donation-esque bonuses
    end
end

--- Replaces the donation machine with the special Archipelago beggar.
--- @param type EntityType
--- @param variant integer
--- @param subType integer
--- @param position Vector
--- @param velocity Vector
--- @param spawnerEntity Entity|nil
--- @param seed integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, type, variant, subType, position, velocity, spawnerEntity, seed)
    if type ~= EntityType.ENTITY_SLOT or (variant ~= SlotVariant.DONATION_MACHINE and variant ~= SlotVariant.GREED_DONATION_MACHINE) then
        return
    end

    return {beggarType, beggarVariant, 0, seed}
end)

--- Fired when the player bumps into the Archipelago beggar.
--- @param playerEntity EntityPlayer
--- @param collidedEntity Entity
--- @param low boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function (_, playerEntity, collidedEntity, low)
    if collidedEntity.Type ~= beggarType or collidedEntity.Variant ~= beggarVariant then -- Archi beggar only
        return
    end

    if not collidedEntity:GetSprite():IsPlaying("Idle") then -- Needs to not be animating
        return
    end

    if playerEntity:GetNumCoins() < 15 then -- Player is too poor to pay :(
        return
    end

    playerEntity:AddCoins(-15)
    collidedEntity:GetSprite():Play("PayPrize", true)
    sfx:Play(SoundEffect.SOUND_SCAMPER)
end)

--- Fired when you blow up the Archipelago beggar.
--- @param entity Entity
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    if entity.Variant ~= beggarVariant then
        return
    end

    -- Spawn 6 - 14 pennies on death
    local rng = util.getRNG()
    for _ = 1, rng:RandomInt(6, 14), 1 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, entity.Position, rng:RandomVector())
    end
end, EntityType.ENTITY_SLOT)

--- Update cycle for the Archipelago beggar.
--- @param beggarEntity Entity
local function updateBeggar(beggarEntity)
    local sprite = beggarEntity:GetSprite()

    if sprite:IsFinished("PayPrize") then -- After the payment animation, play the prize animation
        sprite:Play("Prize", true)
    end
    
    if sprite:IsFinished("Prize") then -- After the prize animation, play the idle animation and reward the check
        sprite:Play("Idle", true)
        awardDonationCheck()
    end
end

--- There is no other way to update a custom slot entity. Please. Please. Please. Please. Please.
--- This calls the update cycle for the beggar.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == beggarType and entity.Variant == beggarVariant then
            updateBeggar(entity)
            return -- There will basically always be only one of these in the room at a time.
        end
    end
end)