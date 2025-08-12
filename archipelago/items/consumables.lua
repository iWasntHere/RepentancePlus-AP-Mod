local cardData = require("archipelago.data.consumable_data")
local util = require("archipelago.util")

--- When starting a new game, fix pill effects.
--- @param continued boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    --[[ TODO: Re-enable once I'm able to generate lua for ALL pills (we're missing I Can See Forever and Phermones)
    if continued then -- Only on new runs pls
        return
    end

    local rng = util.getRNG()

    local pills = cardData.pill

    -- Filter out locked pills
    local usablePills = {}
    for _, pillType in ipairs(pills) do
        local pillCode = AP_MAIN_MOD.ITEMS_DATA.PILL_ID_TO_CODE[pillType]
        if pillCode == nil then -- Error checking
            AP_MAIN_MOD:Error("No code for PillType " .. tostring(pillType), false)
        end
        
        if AP_MAIN_MOD:checkUnlocked(pillCode) then
            usablePills[#usablePills + 1] = pillType
        end
    end

    -- If all pills are locked..?
    if #usablePills == 0 then
        Isaac.ConsoleOutput("All pills are locked\n")
        return
    end

    util.shuffle_table(rng, usablePills)

    -- This is actually horrible. We can't assign pillEffects to individual colours, so we just
    -- cross our fingers and hope, I guess. Stupid. Wait until all 13 colours are assigned
    local pillColors = {}
    local i = 1
    while #pillColors < 13 do
        if i > #usablePills then -- Wrap the value in case we don't have enough pills
            i = math.fmod(i, #usablePills) + 1
        end

        pillColors[Isaac.AddPillEffectToPool(usablePills[i])] = true

        i = i + 1
    end
    --]]
end)

--- Returns an unlocked cardType type, if the given cardType is locked. Else, it returns the given CardType.
--- @param rng RNG
--- @param cardType Card
--- @param includePlaying boolean
--- @param includeRunes boolean
--- @param onlyRunes boolean
--- @return Card
local function rollCard(rng, cardType, includePlaying, includeRunes, onlyRunes)
    if AP_MAIN_MOD:checkUnlocked(AP_MAIN_MOD.ITEMS_DATA.CARD_ID_TO_CODE[cardType]) then -- This card is unlocked, we don't need to replace it
        return cardType
    end

    local allSets = {}

    if onlyRunes then
        allSets = cardData.rune
    else
        -- Gather applicable sets
        local sets = {cardData.TAROT_TYPE, cardData.REVERSE_TYPE, cardData.SPECIAL_TYPE, cardData.OBJECT_TYPE}

        if includePlaying then
            sets[#sets + 1] = cardData.SUIT_TYPE
        end

        if includeRunes then
            sets[#sets + 1] = cardData.RUNE_TYPE
        end

        allSets = util.concatArrays(sets)
    end

    local cardSet = {}
    -- Filter the set down to only unlocked cards
    for _, card in ipairs(allSets) do
        local code = AP_MAIN_MOD.ITEMS_DATA.CARD_ID_TO_CODE[card]
        if code == nil then
            AP_MAIN_MOD:Error("nil card code for card type " .. tostring(card))
        end

        if AP_MAIN_MOD:checkUnlocked(code) then
            --print("Unlocked!")
            cardSet[#cardSet + 1] = card
        end
    end

    -- If there are no unlocked consumables to pick, return Rules Card (lol)
    if #cardSet == 0 then
        return Card.CARD_RULES
    end

    return util.randomFromArray(rng, cardSet)
end

--- When rolling a new card.
--- NOTE: This *does not* work on Booster Pack (WHYYYY).
--- @param rng RNG
--- @param card Card
--- @param includePlaying boolean
--- @param includeRunes boolean
--- @param onlyRunes boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_GET_CARD, function (_, rng, card, includePlaying, includeRunes, onlyRunes)
    return rollCard(rng, card, includePlaying, includeRunes, onlyRunes)
end)

--- When a card is spawned or is in an entered room (fixes booster pack, rune bag).
--- @param entityType EntityType
--- @param variant integer
--- @param subType integer
--- @param position Vector
--- @param velocity Vector
--- @param spawnerEntity Entity|nil
--- @param seed integer
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function (_, entityType, variant, subType, position, velocity, spawnerEntity, seed)
    if entityType ~= EntityType.ENTITY_PICKUP or variant ~= PickupVariant.PICKUP_TAROTCARD then
        return
    end

    local rng = RNG()
    rng:SetSeed(seed, 35)

    -- Spawned from Rune Bag (WHY DON'T YOU USE THE GETCARD CALLBACK ARGH)
    if spawnerEntity and spawnerEntity.Type == EntityType.ENTITY_FAMILIAR and spawnerEntity.Variant == FamiliarVariant.RUNE_BAG then
        subType = rollCard(rng, subType, false, true, true)
    else
        local itemConfig = Isaac.GetItemConfig()
        local itemConfigCard = itemConfig:GetCard(subType)

        if itemConfigCard:IsCard() then -- Cards should reroll into other cards
            subType = rollCard(rng, subType, true, false, false)
        else -- Anything else should reroll into anything (I guess)
            subType = rollCard(rng, subType, true, true, false)
        end
    end

    return {entityType, variant, subType, seed}
end)