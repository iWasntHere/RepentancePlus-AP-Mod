local util = require("util")
local sfx = SFXManager()

local page = 1

local pages = {
    require("tracker/character_tracker"),
    require("tracker/stage_tracker"),
    require("tracker/item_tracker"),
    require("tracker/baby_tracker")
}

local fadeSprite = Sprite()
fadeSprite:Load("gfx/ui/Fade.anm2", true)

local trackerXPosition = Isaac.GetScreenWidth() * 2
local trackerYPosition = 0

local wasOutLastFrame = false

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    local isOut = false
    local screenWidth = Isaac.GetScreenWidth()

    if Input.IsButtonPressed(Keyboard.KEY_BACKSLASH, 0) then -- Pulling it out
        isOut = true
        trackerXPosition = util.lerp(trackerXPosition, 0, 0.1)

        -- Up/Down controls
        if Input.IsButtonTriggered(Keyboard.KEY_ENTER, 0) and page > 1 then
            page = page - 1
            sfx:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 2, false, 0.9 + (math.random() * 0.1))
        end

        if Input.IsButtonTriggered(Keyboard.KEY_RIGHT_SHIFT, 0) and page < #pages then
            page = page + 1
            sfx:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 2, false, 0.9 + (math.random() * 0.1))
        end
    else -- Putting it away
        trackerXPosition = util.lerp(trackerXPosition, Isaac.GetScreenWidth() * 1.1, 0.1)
    end

    if not wasOutLastFrame and isOut then
        -- We just pulled it out
        sfx:Play(SoundEffect.SOUND_PAPER_IN)
        fadeSprite:Play("FadeIn", true)
    elseif wasOutLastFrame and not isOut then
        -- We just put it away
        sfx:Play(SoundEffect.SOUND_PAPER_OUT)
        fadeSprite:Play("FadeOut", true)
    end

    fadeSprite:Update()

    wasOutLastFrame = isOut

    -- If the tracker is off the screen, then don't render it
    if trackerXPosition > screenWidth then
        return
    end

    local width = Isaac.GetScreenWidth()
    local height = Isaac.GetScreenHeight()

    -- For the vertical scrolling effect
    trackerYPosition = util.lerp(trackerYPosition, (page - 1) * -Isaac.GetScreenHeight(), 0.1)

    fadeSprite:Render(Vector(0, 0))
    for index, func in ipairs(pages) do
        local offset = Vector(trackerXPosition, trackerYPosition + ((index - 1) * height))

        func(offset, page == index, sfx)
    end
end)