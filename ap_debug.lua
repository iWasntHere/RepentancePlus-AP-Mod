local consumableData = require("consumable_data")

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not Input.IsButtonPressed(Keyboard.KEY_BACKSLASH, 0) then
        return
    end

    Isaac.RenderScaledText("Pills", 64, 48, 0.5, 0.5, 1, 1, 1, 1)

    local x = 64
    local y = 64
    for _, pill in ipairs(consumableData.pill) do
        local pillName = consumableData.pillNames[pill + 1] -- Lua arrays don't start at 0
        local unlocked = AP_SUPP_MOD.itemStates["Pill-" .. tostring(pill)]

        if unlocked then
            Isaac.RenderScaledText(pillName, x, y, 0.5, 0.5, 0, 1, 0, 1)
        else
            Isaac.RenderScaledText(pillName, x, y, 0.5, 0.5, 1, 0, 0, 1)
        end

        y = y + 16

        if y > 256 then
            y = 64
            x = x + 64
        end
    end
end)