local util = require("util")
local font = Font()
font:Load("font/teammeatfont12.fnt")

local smallFont = Font()
smallFont:Load("font/teammeatfont10.fnt")

-- The order that stages appear in
local stageProgression = {
    { -- Chapter 1 / 1 Alt
        {item = nil, anim = "Basement"},
        {item = "The Cellar", anim = "Cellar"},
        {item = "Burning Basement", anim = "Burning Basement"},
        {item = "A Secret Exit", anim = "Downpour"},
        {item = "Dross", anim = "Dross"},
    },
    { -- Chapter 2 / 2 Alt
        {item = nil, anim = "Caves"},
        {item = "The Catacombs", anim = "Catacombs"},
        {item = "Flooded Caves", anim = "Flooded Caves"},
        {item = "A Secret Exit", anim = "Mines"},
        {item = "Ashpit", anim = "Ashpit"},
    },
    { -- Chapter 3 / 3 Alt
        {item = nil, anim = "Depths"},
        {item = "The Necropolis", anim = "Necropolis"},
        {item = "Dank Depths", anim = "Dank Depths"},
        {item = "A Secret Exit", anim = "Mausoleum"},
        {item = "Gehenna", anim = "Gehenna"},
    },
    { -- Chapter 4 / 4 Alt
        {item = "The Womb", anim = "Womb"},
        {item = "The Womb", anim = "Utero"},
        {item = "Scarred Womb", anim = "Scarred Womb"},
        {item = "Blue Womb", anim = "Blue Womb"},
        {item = "A Secret Exit", anim = "Corpse"},
    },
    { -- Chapter 5
        {item = "It Lives!", anim = "Cathedral"},
        {item = "It Lives!", anim = "Sheol"},
    },
    { -- Chapter 6
        {item = "The Polaroid", anim = "The Chest"},
        {item = "The Negative", anim = "Dark Room"},
    },
    { -- Chapter ?
        {item = "A Mysterious Door", anim = "Home"},
        {item = "New Area", anim = "The Void"}
    }
}

local page = 1
local pages = stageProgression

local stageSprite = Sprite()
stageSprite:Load("gfx/ui/Stages.anm2", true)

local backgroundSprite = Sprite()
backgroundSprite:Load("gfx/ui/Tracker_Page.anm2", true)
backgroundSprite:Play("Stages")

local BG_WIDTH = 304
local BG_HEIGHT = 212

--- Renders the item tracker page.
--- @param offset Vector The pixel offset to draw at
--- @param canControl boolean Whether you can control the page or not
--- @param sfx SFXManager The SFX manager
return function(offset, canControl, sfx)
    -- Page previous/back controls
    if canControl then
        if Input.IsButtonTriggered(Keyboard.KEY_RIGHT_BRACKET, 0) and page < #pages then
            page = page + 1
            sfx:Play(SoundEffect.SOUND_CHARACTER_SELECT_RIGHT)
        end

        if Input.IsButtonTriggered(Keyboard.KEY_LEFT_BRACKET, 0) and page > 1 then
            page = page - 1
            sfx:Play(SoundEffect.SOUND_CHARACTER_SELECT_LEFT)
        end
    end

    local screenWidth = Isaac.GetScreenWidth()
    local screenHeight = Isaac.GetScreenHeight()

    -- This is the origin of the entire ui
    local pageTopLeft = Vector(
        offset.X + ((screenWidth / 2) - (BG_WIDTH / 2)),
        offset.Y + ((screenHeight / 2) - (BG_HEIGHT / 2))
    )

    backgroundSprite:Render(pageTopLeft)

    local columnStart = pageTopLeft.X + 64
    local rowStart = pageTopLeft.Y + 80

    local row = 0
    local column = 0
    
    for _, curPage in ipairs(pages) do
        for _, itemAndAnim in ipairs(curPage) do
            local x = columnStart + (32 * column)
            local y = rowStart + (24 * row)

            local unlocked = true
            if itemAndAnim.item ~= nil then
                unlocked = AP_MAIN_MOD:checkUnlockedByName(itemAndAnim.item)
            end

            local anim = itemAndAnim.anim
            if not unlocked then -- Locked icon variant
                anim = "Locked" .. anim
            end

            stageSprite:Play(anim, true)
            stageSprite:Render(Vector(x - 8, y)) -- Render the item's icon

            row = row + 1
        end

        -- Set up to draw the next column
        row = 0
        column = column + 1
    end
end