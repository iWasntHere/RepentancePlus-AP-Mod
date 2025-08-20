local util = Archipelago.util
local sfxManager = Archipelago.sfxManager
local font = Archipelago.fonts.TeamMeat12
local smallFont = Archipelago.fonts.TeamMeat10

local page = 1
local pages = nil -- This will be populated when the user first opens the page

local backgroundSprite = Sprite()
backgroundSprite:Load("gfx/ui/Tracker_Page.anm2", true)
backgroundSprite:Play("Items")

local BG_WIDTH = 304
local BG_HEIGHT = 212

local babySprite = Sprite()
babySprite:Load("gfx/001.001_player2.anm2", false)

-- For whatever reason, I can't load my own graphic into the game's anm2,
-- so I have to supply my own anm2 :/
local missingBabySprite = Sprite()
missingBabySprite:Load("gfx/ui/Missing_Baby.anm2", true)
missingBabySprite:Play("Idle")

--- Renders the baby tracker page.
--- @param offset Vector The pixel offset to draw at
--- @param canControl boolean Whether you can control the page or not
return function(offset, canControl)
    -- The pages array is populated here since at launch time the globalvar isn't available yet
    if pages == nil then
        pages = util.chunkArray(TARGET_BABY_CODES, 9)
    end

    -- Page previous/back controls
    if canControl then
        if Input.IsButtonTriggered(Keyboard.KEY_RIGHT_BRACKET, 0) and page < #pages then
            page = page + 1
            sfxManager:Play(SoundEffect.SOUND_CHARACTER_SELECT_RIGHT)
        end

        if Input.IsButtonTriggered(Keyboard.KEY_LEFT_BRACKET, 0) and page > 1 then
            page = page - 1
            sfxManager:Play(SoundEffect.SOUND_CHARACTER_SELECT_LEFT)
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

    local columnStart = pageTopLeft.X + 24
    local rowStart = pageTopLeft.Y + 80

    local row = 0
    local column = 0

    local color = KColor(0.212, 0.184, 0.176, 1)

    font:DrawStringScaled(tostring(page) .. "/" .. tostring(#pages), pageTopLeft.X + 8, pageTopLeft.Y + 8, 0.5, 0.5, color)

    for _, code in ipairs(pages[page]) do
        local x = columnStart + (96 * column)
        local y = rowStart + (48 * row)

        local name = Archipelago.ITEMS_DATA.CODE_TO_NAME[code]
        local unlocked = Archipelago:checkUnlocked(code)

        -- Truncate the name if it's too long
        local clippedName = string.sub(name, 1, 16)
        if clippedName ~= name then
            name = clippedName .. "..."
        end

        if unlocked then
            local skin = Archipelago.BABY_SKIN_DATA[Archipelago.ITEMS_DATA.CODE_TO_BABY_ID[code]]
            babySprite:ReplaceSpritesheet(0, "gfx/characters/player2/" .. skin)
            babySprite:LoadGraphics()
            babySprite:Play("HeadDown", true)
            babySprite:Render(Vector(x + 16, y - 12)) -- Render babby
        else
            missingBabySprite:Render(Vector(x + 16, y - 12))
        end

        color.Alpha = 0.1
        smallFont:DrawStringScaled(tostring(code), x, y - 6, 0.5, 0.5, color)

        if unlocked then
            color.Alpha = 1
            font:DrawStringScaled(name, x, y, 0.5, 0.5, color)
        else
            color.Alpha = 0.25
            font:DrawStringScaled(name, x, y, 0.5, 0.5, color)
        end

        row = row + 1

        if row >= 3 then
            row = 0
            column = column + 1
        end
    end
end