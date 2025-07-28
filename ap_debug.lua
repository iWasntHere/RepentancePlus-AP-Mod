local util = require("util")

local page = 1
local pages = util.chunk_array(AP_MAIN_MOD.ITEMS_DATA.CODES, 78)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not Input.IsButtonPressed(Keyboard.KEY_BACKSLASH, 0) then
        return
    end

    -- Page up/down controls
    if Input.IsButtonTriggered(Keyboard.KEY_RIGHT_BRACKET, 0) then
        page = page + 1
    end

    if Input.IsButtonTriggered(Keyboard.KEY_LEFT_BRACKET, 0) then
        page = page - 1
    end

    page = util.clamp(page, 1, #pages)

    Isaac.RenderScaledText("Items (Page " .. tostring(page) .. " / " .. tostring(#pages) .. ")", 64, 48, 0.5, 0.5, 1, 1, 1, 1)

    local x = 64
    local y = 64
    for _, code in ipairs(pages[page]) do
        local name = AP_MAIN_MOD.ITEMS_DATA.CODE_TO_NAME[code]
        local unlocked = AP_MAIN_MOD:checkUnlocked(code)

        -- Truncate the name if it's too long
        local clippedName = string.sub(name, 1, 16)
        if clippedName ~= name then
            name = clippedName .. "..."
        end

        Isaac.RenderScaledText(tostring(code), x - 4, y - 4, 0.5, 0.5, 1, 1, 1, 0.25)

        if unlocked then
            Isaac.RenderScaledText(name, x, y, 0.5, 0.5, 0, 1, 0, 1)
        else
            Isaac.RenderScaledText(name, x, y, 0.5, 0.5, 1, 0, 0, 1)
        end

        y = y + 16

        if y > 256 then
            y = 64
            x = x + 64
        end
    end
end)