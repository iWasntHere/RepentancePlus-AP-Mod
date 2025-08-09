local util = require("archipelago.util")
local font = Font()
font:Load("font/teammeatfont12.fnt")

local smallFont = Font()
smallFont:Load("font/teammeatfont10.fnt")

local page = 1
local pages = util.chunk_array(AP_MAIN_MOD.ITEMS_DATA.CODES, 30)

local itemTypeSprite = Sprite() -- Used to render icons next to item names to show type
itemTypeSprite:Load("gfx/ui/Tracker_Icons.anm2", true)

local backgroundSprite = Sprite()
backgroundSprite:Load("gfx/ui/Tracker_Page.anm2", true)
backgroundSprite:Play("Items")

local BG_WIDTH = 304
local BG_HEIGHT = 212

local TYPE_TO_ICON = {
    Suit = "Card",
    Tarot = "Card",
    Special = "Card",
    Object = "Object",
    Reverse_Tarot = "Card",
    Rune = "Rune",
    Pill = "Pill",
    Character = "Character",
    Tainted_Character = "TaintedCharacter",
    Item = "Collectible",
    Trinket = "Trinket",
    Challenge = "Challenge",
    ["Co-Op_Baby"] = "Baby"
}

local NAME_TO_ICON = {
    ["The Womb"] = "Floor",
    ["Blue Womb"] = "Floor",
    ["New Area"] = "Floor",
    ["It Lives!"] = "Floor",
    ["A Secret Exit"] = "Floor",
    ["A Strange Door"] = "Floor",

    ["Burning Basement"] = "Floor",
    ["Flooded Caves"] = "Floor",
    ["Dank Depths"] = "Floor",
    ["Scarred Womb"] = "Floor",

    ["The Cellar"] = "Floor",
    ["The Catacombs"] = "Floor",
    ["The Necropolis"] = "Floor",

    ["Dross"] = "Floor",
    ["Ashpit"] = "Floor",
    ["Gehenna"] = "Floor",
}

-- Returns an icon for a given item code in the item tracker
local function getIcon(code)
    local type = AP_MAIN_MOD.ITEMS_DATA.CODE_TO_TYPE[code]
    if TYPE_TO_ICON[type] then
        return TYPE_TO_ICON[type]
    end

    -- No type for this, so try by name
    local name = AP_MAIN_MOD.ITEMS_DATA.CODE_TO_NAME[code]
    if NAME_TO_ICON[name] then
        return NAME_TO_ICON[name]
    end

    return "Unknown"
end

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

    local columnStart = pageTopLeft.X + 24
    local rowStart = pageTopLeft.Y + 38

    local row = 0
    local column = 0

    local color = KColor(0.212, 0.184, 0.176, 1)

    font:DrawStringScaled(tostring(page) .. "/" .. tostring(#pages), pageTopLeft.X + 8, pageTopLeft.Y + 8, 0.5, 0.5, color)
    
    for _, code in ipairs(pages[page]) do
        local x = columnStart + (96 * column)
        local y = rowStart + (16 * row)

        local name = AP_MAIN_MOD.ITEMS_DATA.CODE_TO_NAME[code]
        local unlocked = AP_MAIN_MOD:checkUnlocked(code)

        local icon = getIcon(code)

        if not unlocked then -- Locked icon variant
            icon = "Locked" .. icon
        end

        itemTypeSprite:Play(icon, true)

        -- Truncate the name if it's too long
        local clippedName = string.sub(name, 1, 16)
        if clippedName ~= name then
            name = clippedName .. "..."
        end

        itemTypeSprite:Render(Vector(x - 8, y)) -- Render the item's icon

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

        if row >= 10 then
            row = 0
            column = column + 1
        end
    end
end