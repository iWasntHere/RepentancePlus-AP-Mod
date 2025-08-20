local util = Archipelago.util

local beggarType = Isaac.GetEntityTypeByName("Archipelago Beggar")
local beggarVariant = Isaac.GetEntityVariantByName("Archipelago Beggar")

local graveVariant = Isaac.GetEntityVariantByName("Beggar Grave")

local sfx = SFXManager()
local Locations = Archipelago.LOCATIONS_DATA.LOCATIONS
local stats = Archipelago.stats

local SlotVariant = {
    DONATION_MACHINE = 8,
    GREED_DONATION_MACHINE = 11
}

--- Awards the next location for donating on the current game mode.
local function awardDonationCheck()
    local isGreedMode = Archipelago.game:IsGreedMode()
    local key = stats.StatKeys.SHOP_DONATIONS
    local locationCode = Locations.SHOP_DONATION

    if isGreedMode then
        key = stats.StatKeys.GREED_DONATIONS
        locationCode = Locations.GREED_DONATION
    end

    local donations = stats.incrementStat(key)
    Archipelago:sendLocation(locationCode + (donations - 1))

    if not isGreedMode then
        -- TODO: Give donation-esque bonuses
    end
end

Archipelago:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then
        return
    end

    -- Unkill the beggar
    stats.setStat(stats.StatKeys.DONATION_BEGGAR_KILLED_THIS_RUN, false)
end)

--- Replaces the donation machine with the special Archipelago beggar.
--- @param type EntityType
--- @param variant integer
--- @param subType integer
--- @param position Vector
--- @param velocity Vector
--- @param spawnerEntity Entity|nil
--- @param seed integer
Archipelago:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, type, variant, subType, position, velocity, spawnerEntity, seed)
    if type ~= EntityType.ENTITY_SLOT or (variant ~= SlotVariant.DONATION_MACHINE and variant ~= SlotVariant.GREED_DONATION_MACHINE) then
        return
    end

    -- Don't spawn the beggar if they are dead, instead spawn a grave (lmao)
    if stats.getStat(stats.StatKeys.DONATION_BEGGAR_KILLED_THIS_RUN, false) then
        return {EntityType.ENTITY_PICKUP, graveVariant, 0, seed}
    end

    return {beggarType, beggarVariant, 0, seed}
end)

--- Fired when the player bumps into the Archipelago beggar.
--- @param playerEntity EntityPlayer
--- @param collidedEntity Entity
--- @param low boolean
Archipelago:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function (_, playerEntity, collidedEntity, low)
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
Archipelago:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    if entity.Variant ~= beggarVariant then
        return
    end

    -- Spawn 6 - 14 pennies on death
    local rng = util.getRNG()
    local game = Archipelago.game
    local seed = game:GetRoom():GetSpawnSeed()
    for _ = 0, rng:RandomInt(8) + 6, 1 do
        game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, entity.Position, util.randomVector(rng) * (rng:RandomFloat() * 5.0), entity, CoinSubType.COIN_PENNY, seed)
    end

    -- Mark beggar as killed
    stats.setStat(stats.StatKeys.DONATION_BEGGAR_KILLED_THIS_RUN, true)
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
Archipelago:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == beggarType and entity.Variant == beggarVariant then
            updateBeggar(entity)
            return -- There will basically always be only one of these in the room at a time.
        end
    end
end)

--- For when the beggar is exploded, violently.
--- @param entity Entity
Archipelago:AddCallback(Archipelago.Callbacks.MC_ARCHIPELAGO_PRE_SLOT_KILLED, function (_, entity)
    if entity.Variant ~= beggarVariant then
        return
    end

    entity:Kill()
    entity:Remove()
end)