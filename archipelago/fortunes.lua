local util = Archipelago.util

--- Shows a fortune by splitting it at |s.
--- @param fortune string
local function showSplitFortune(fortune)
    local split = util.stringSplit(fortune, "|")
    Archipelago.hud:ShowFortuneText(table.unpack(split))
end

--- Replaces a fortune shown by Fortune Cookie or Fortune Teller.
Archipelago:AddCallback(Archipelago.Callbacks.MC_ARCHIPELAGO_FORTUNE_TELLER_FORTUNE, function (_)
    -- This doesn't need to be seeded. I don't really care right now.

    local typeVal = math.random()
    local fortune = nil

    -- AP Hint (30%)
    if typeVal < 0.3 then
        local characterName = util.getCharacterName()
        local hints = {}
        
        -- Hints for the current character are much more likely
        for _, data in ipairs(ARCHIPELAGO_HINTS[characterName]) do
            hints[#hints + 1] = {
                value = data.text,
                weight = 1
            }
        end

        -- Global hints aren't as likely
        for _, data in ipairs(ARCHIPELAGO_HINTS["Global"]) do
            hints[#hints + 1] = {
                value = data.text,
                weight = 0.1
            }
        end

        showSplitFortune(util.chooseWeighted(hints))

    -- AP fortune (80%)
    elseif typeVal < 0.8 then
        fortune = Archipelago.FORTUNES[math.random(#Archipelago.FORTUNES)]
        showSplitFortune(fortune)
    end
end)