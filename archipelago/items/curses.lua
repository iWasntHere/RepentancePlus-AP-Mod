local util = Archipelago.util

--- @param curses integer
Archipelago:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, function (_, curses)
    local isTerrible = Archipelago:checkUnlockedByName("Everything is Terrible!!!")
    local difficulty = Archipelago.game.Difficulty

    -- Calculate the chance for a curse
    local denom = 80
    if difficulty == Difficulty.DIFFICULTY_HARD then
        if not isTerrible then
            denom = 10
        else
            denom = 3
        end
    else
        if isTerrible then
            denom = 10
        end
    end

    -- Get RNG and iterate it so we can maintain the game's seed
    local rng = util.getRNG()
    for _ = 0, Archipelago.level():GetStage(), 1 do
        rng:Next()
    end

    -- We want the chance that you *don't* get a curse
    if rng:RandomFloat() > (1 / denom) then
        return 0
    end
end)