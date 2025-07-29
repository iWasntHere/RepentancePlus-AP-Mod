AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, function (_, curses)
    -- If no Everything is Terrible!!!, then just remove all curses
    if not AP_MAIN_MOD:checkUnlockedByName("Everything is Terrible!!!") then
        return 0
    end
end)