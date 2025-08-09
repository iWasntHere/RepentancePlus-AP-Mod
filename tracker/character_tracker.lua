local util = require("util")
local font = Font()
font:Load("font/teammeatfont12.fnt")

local smallFont = Font()
smallFont:Load("font/teammeatfont10.fnt")

local page = 1
local pages = util.chunk_array(AP_MAIN_MOD.CHARACTER_DATA.ItemNames, 4)

local backgroundSprite = Sprite()
backgroundSprite:Load("gfx/ui/Tracker_Page.anm2", true)
backgroundSprite:Play("Characters")

local BG_WIDTH = 304
local BG_HEIGHT = 212

local characterSprite = Sprite()
characterSprite:Load("gfx/ui/Characters.anm2", true)

local marksSprite = Sprite()
marksSprite:Load("gfx/ui/Completion_Marks.anm2", true)

local function drawMarks(marks, x, y)
    if marks == nil then -- We don't really want it to be nil.
        marks = {}
    end

    local numMarks = #AP_MAIN_MOD.CHARACTER_DATA.CompletionMarks
    local twoPi = 2 * math.pi
    for i, mark in ipairs(AP_MAIN_MOD.CHARACTER_DATA.CompletionMarks) do
        local xx = x + math.cos((i / numMarks) * twoPi) * 32
        local yy = y + math.sin((i / numMarks) * twoPi) * 32

        local anim = mark

        if marks[mark] == nil then -- Play a different anim if it was locked still
            anim = "Locked" .. anim
        end

        marksSprite:Play(anim, true)
        marksSprite:Render(Vector(xx, yy))
    end
end

--- Renders the baby tracker page.
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

    local columnStart = pageTopLeft.X + 70
    local rowStart = pageTopLeft.Y + 102

    local row = 0
    local column = 0

    local color = KColor(0.212, 0.184, 0.176, 1)

    font:DrawStringScaled(tostring(page) .. "/" .. tostring(#pages), pageTopLeft.X + 8, pageTopLeft.Y + 8, 0.5, 0.5, color)

    local marks = AP_SUPP_MOD:LoadKey("completion_marks", {})

    for _, name in ipairs(pages[page]) do
        local x = columnStart + (52 * column)
        local y = rowStart + (82 * row)

        local code = AP_MAIN_MOD.ITEMS_DATA.NAME_TO_CODE[name]
        local unlocked = AP_MAIN_MOD:checkUnlocked(code)

        local animName = AP_MAIN_MOD.CHARACTER_DATA.ItemNameToInternalName[name]
        if not unlocked then
            animName = "Locked" .. animName
        end

        color.Alpha = 0.1
        smallFont:DrawStringScaled(tostring(code), x - 32, y - 6, 0.5, 0.5, color)

        characterSprite:Play(animName, true)
        characterSprite:Render(Vector(x, y - 40))

        local textXOffset = -font:GetStringWidth(name) * 0.25

        if unlocked then
            color.Alpha = 1
            font:DrawStringScaled(name, x + textXOffset, y, 0.5, 0.5, color)
        else
            color.Alpha = 0.25
            font:DrawStringScaled(name, x + textXOffset, y, 0.5, 0.5, color)
        end

        drawMarks(marks[AP_MAIN_MOD.CHARACTER_DATA.ItemNameToInternalName[name]], x, y - 40)

        row = row + 1
        column = column + 1

        if row >= 2 then
            row = 0
        end
    end
end