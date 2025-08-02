local util = require "util"
local beggarType = Isaac.GetEntityTypeByName("Archipelago Beggar")
local beggarVariant = Isaac.GetEntityVariantByName("Archipelago Beggar")
local sfx = SFXManager()

local SlotVariant = {
    DONATION_MACHINE = 8,
    GREED_DONATION_MACHINE = 11
}

local function awardDonationCheck()
    local isGreedMode = Game():IsGreedMode()
    local key = "donations"
    local locationCode = AP_MAIN_MOD.LOCATIONS_DATA["Shop Donation"]

    if isGreedMode then
        key = "greed_donations"
        locationCode = AP_MAIN_MOD.LOCATIONS_DATA["Greed Donation"]
    end

    print(locationCode)

    local donations = AP_SUPP_MOD:LoadKey(key, 0)
    donations = donations + 1
    AP_MAIN_MOD:sendLocation(locationCode + donations)
    AP_SUPP_MOD:SaveKey(key, donations)

    if not isGreedMode then
        -- TODO: Give donation-esque bonuses
    end
end

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, type, variant, subType, position, velocity, spawnerEntity, seed)
    if type ~= EntityType.ENTITY_SLOT or (variant ~= SlotVariant.DONATION_MACHINE and variant ~= SlotVariant.GREED_DONATION_MACHINE) then
        return
    end

    print("replace")

    return {beggarType, beggarVariant, 0, seed}
end)

-- Handles donating
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function (_, playerEntity, collidedEntity, low)
    if collidedEntity.Type ~= beggarType or collidedEntity.Variant ~= beggarVariant then -- Archi beggar only
        return
    end

    if not collidedEntity:GetSprite():IsPlaying("Idle") then -- Needs to not be animating
        return
    end

    if playerEntity:GetNumCoins() < 0 then -- Player is too poor to pay :(
        return
    end

    playerEntity:AddCoins(1)
    collidedEntity:GetSprite():Play("PayPrize", true)
    sfx:Play(SoundEffect.SOUND_SCAMPER)
end)

-- For when you blow this sucker up
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

--- Update cycle for the archipelago beggar
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

-- There is no other way to update a custom slot entity. Please. Please. Please. Please. Please.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == beggarType and entity.Variant == beggarVariant then
            updateBeggar(entity)
            return -- There will basically always be only one of these in the room at a time.
        end
    end
end)