--- Handles locations involved with completing challenges.
--- @param type EntityType
--- @param variant integer
--- @param subType integer
Archipelago:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, type, variant, subType)
    if type ~= EntityType.ENTITY_PICKUP or variant ~= PickupVariant.PICKUP_TROPHY then
        return
    end

    local challengeId = Archipelago.game.Challenge
    local locationName = Archipelago.CHALLENGE_DATA.CHALLENGE_ID_TO_NAME[challengeId]

    if locationName == nil then -- Shouldn't happen, but the challenge has no name associated
        print("Challenge " .. tostring(challengeId) .. " has no name!")
        return
    end

    local code = Archipelago.LOCATIONS_DATA.NAME_TO_CODE[locationName]

    if code == nil then -- Shouldn't happen, but the location name has no code associated
    print("Challenge location '" .. locationName .. "' has no code!")
        return
    end

    Archipelago:sendLocation(code)
end)