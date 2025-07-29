local cardData = require("data/consumable_data")
local util = require("util")

-- When starting a new game, fix pill effects
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then -- Only on new runs pls
        return
    end

    local startSeed = Game():GetSeeds():GetStartSeed()
    local rng = RNG()
    rng:SetSeed(startSeed, 35)

    local pills = cardData.pill

    -- Filter out locked pills
    local usablePills = {}
    for _, pillType in ipairs(pills) do
        if AP_MAIN_MOD:checkUnlocked(AP_MAIN_MOD.ITEMS_DATA.PILL_ID_TO_CODE[pillType]) then
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
end)

-- When rolling a new card
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_GET_CARD, function (_, rng, card, includePlaying, includeRunes, onlyRunes)
    if AP_MAIN_MOD:checkUnlocked(AP_MAIN_MOD.ITEMS_DATA.CARD_ID_TO_CODE[card]) then -- This card is unlocked, we don't need to replace it
        return nil
    end

    local cardSet = {}

    if onlyRunes then
        cardSet = cardData.rune
    else
        -- Gather applicable sets
        local sets = {cardData.tarot, cardData.reverse, cardData.special, cardData.object}

        if includePlaying then
            sets[#sets] = cardData.suit
        end

        if includeRunes then
            sets[#sets] = cardData.rune
        end
        
        local allSets = util.merge_arrays(sets)

        -- Filter the set down to only unlocked cards
        for _, cardType in ipairs(allSets) do
            if AP_MAIN_MOD:checkUnlocked(AP_MAIN_MOD.ITEMS_DATA.CARD_ID_TO_CODE[cardType]) then
                cardSet[#cardSet + 1] = cardType
            end
        end
    end

    -- If there are no unlocked consumables to pick, return Rules Card (lol)
    if #cardSet == 0 then
        return Card.CARD_RULES
    end

    return util.random_from_array(rng, cardSet)
end)