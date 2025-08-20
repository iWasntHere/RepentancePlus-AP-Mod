local apConsumableType = Isaac.GetCardIdByName("Soul of The Multiworld")
local stats = require("archipelago.stats")
local Locations = AP_MAIN_MOD.LOCATIONS_DATA.LOCATIONS

--- For when you use the AP Consumable.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)
    local uses = stats.incrementStat(stats.StatKeys.AP_CONSUMABLE_USES)
    AP_MAIN_MOD:sendLocation(Locations.AP_CONSUMABLE + (uses - 1))
end, apConsumableType)