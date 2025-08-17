--- Handles locations involved with completing challenges.
--- @param type EntityType
--- @param variant integer
--- @param subType integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, type, variant, subType)
    if type ~= EntityType.ENTITY_PICKUP or variant ~= PickupVariant.PICKUP_TROPHY then
        return
    end

    local challengeId = Game().Challenge
    local locationName = AP_MAIN_MOD.CHALLENGE_DATA.CHALLENGE_ID_TO_NAME[challengeId]

    if locationName == nil then -- Shouldn't happen, but the challenge has no name associated
        print("Challenge " .. tostring(challengeId) .. " has no name!")
        return
    end

    local code = AP_MAIN_MOD.LOCATIONS_DATA.NAME_TO_CODE[locationName]

    if code == nil then -- Shouldn't happen, but the location name has no code associated
    print("Challenge location '" .. locationName .. "' has no code!")
        return
    end

    AP_MAIN_MOD:sendLocation(code)
end)