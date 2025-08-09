-- Handles drawing the fun confetti effect that happens when you get a check

local confettiVariant = Isaac.GetEntityVariantByName("Confetti")

local colours = {
    "Red",
    "Blue",
    "Green",
    "Yellow"
}

--- Sets the colour of the confetti
--- @param effect EntityEffect
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
    effect:GetSprite():Play(colours[math.random(#colours)], true)

    effect.PositionOffset = Vector(0, -math.random(128, 256))

    effect:GetData().FallSpeed = 1 + (math.random() * 5)
end, confettiVariant)

--- Render confetti
--- @param effect EntityEffect
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    -- Float down
    effect.PositionOffset = Vector(0, math.min(effect.PositionOffset.Y + effect:GetData().FallSpeed, 0))

    -- Stop animating when landed
    if effect.PositionOffset.Y == 0 then
        effect:GetSprite():Stop()
    end
end, confettiVariant)

-- Reset confetti when moving to a new room
local currentRoomConfetti = 0
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    currentRoomConfetti = 0
end)

--- Spawns confetti!!!
--- @param number integer Amount of confetti to spawn
return function(number)
    if currentRoomConfetti > 128 then -- Limit the amount of confetti that can spawn per room
        return
    end

    for i = 0, number, 1 do
        currentRoomConfetti = currentRoomConfetti + 1
        Isaac.Spawn(EntityType.ENTITY_EFFECT, confettiVariant, 0, Isaac.GetRandomPosition(), Vector(0, 0), nil)
    end
end