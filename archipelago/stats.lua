local export = {}

--- @enum StatKeys
export.StatKeys = {
    GULP_USES_THIS_RUN = "gulps_this_run",
    ARCADE_VISITED_THIS_FLOOR = "arcade_visited_this_floor",
    LOCKED_CHESTS_OPENED = "locked_chests_opened",
    CARDS_USED = "cards_used",
    DEATH_CARDS_USED = "death_cards_used",
    TOTAL_DEATHS = "total_deaths",
    ARCADES_VISITED = "arcades_visited",
    LIL_BATTERIES_PICKED = "lil_batteries_picked",
    SHOPS_VISITED_THIS_RUN = "shops_visited_this_run",
    SHOP_VISITED_THIS_FLOOR = "shop_visited_this_floor",
    ANGEL_ITEMS_TAKEN = "angel_items_taken",
    DEVIL_ITEMS_TAKEN = "devil_items_taken",
    DEVIL_ITEMS_TAKEN_THIS_RUN = "devil_items_taken_this_run",
    RUBBER_CEMENTS_COLLECTED = "rubber_cements_collected", -- Collect rubber cements
    BLOOD_CLOTS_COLLECTED = "blood_clots_collected", -- Collect blood clots
    SECRET_ROOM_VISITS = "secret_room_visits", -- Visit 50 secret rooms
    SECRET_ROOM_VISITED_THIS_FLOOR = "secret_room_visited_this_floor",
    SUPER_SECRET_ROOM_VISITED_THIS_FLOOR = "super_secret_room_visited_this_floor",
    ULTRA_SECRET_ROOM_VISITED_THIS_FLOOR = "ultra_secret_room_visited_this_floor",
    LAST_RUN_COMPLETED = "last_run_completed", -- Mr Resetter!
    RESETS = "resets", -- Mr Reseter!
    HEARTS_COINS_BOMBS_PICKED_THIS_RUN = "hearts_coins_bombs_picked_this_run", -- It's the Key!
    WIN_STREAK = "win_streak",
    TEARS_UP_PILLS_THIS_RUN = "tears_up_pills_this_run",
    DIED_THIS_RUN = "died_this_run", -- Lazarus @ Mom's Heart w/o Deaths
    CHAPTER_1_CLEARS = "chapter_1_clears",
    CHAPTER_2_CLEARS = "chapter_2_clears",
    CHAPTER_3_CLEARS = "chapter_3_clears",
    LAST_FLOOR_WITH_DAMAGE = "last_floor_with_damage",
    LAST_FLOOR_WITHOUT_HALF_HEART = "last_floor_without_half_heart",
    BATTERY_BUMS_KILLED = "battery_bums_killed",
    SLOT_MACHINES_KILLED = "slot_machines_destroyed",
    SHOPKEEPERS_KILLED = "shopkeepers_killed",
    SHELL_GAME_PLAYS = "shell_game_plays",
    BATTERY_BUM_COLLECTIBLE_PAYOUTS = "battery_bum_collectible_payouts",
    BLOOD_DONATIONS = "blood_donations",
    POOPS_DESTROYED = "poops_destroyed",
    RAINBOW_POOPS_DESTROYED = "rainbow_poops_destroyed",
    ROCKS_DESTROYED = "rocks_destroyed",
    TINTED_ROCKS_DESTROYED = "tinted_rocks_destroyed"
}

--- Increases the given stat by 1, and returns the new value.
--- @param statKey StatKeys
--- @return integer
function export.incrementStat(statKey)
    local value = AP_SUPP_MOD:LoadKey(statKey, 0) + 1
    AP_SUPP_MOD:SaveKey(statKey, value)

    return value
end

--- Sets the given stat to the value.
--- @param statKey StatKeys
--- @param value any
function export.setStat(statKey, value)
    AP_SUPP_MOD:SaveKey(statKey, value)
end

--- Gets the value of the stat key.
--- @param statKey StatKeys
--- @param default any
--- @return any
function export.getStat(statKey, default)
    return AP_SUPP_MOD:LoadKey(statKey, default)
end

return export