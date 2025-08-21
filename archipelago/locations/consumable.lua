Archipelago.SoulOfTheMultiworldType = Isaac.GetCardIdByName("Soul of The Multiworld")
local stats = Archipelago.stats
local Locations = Archipelago.LOCATIONS_DATA.LOCATIONS

--- For when you use the AP Consumable.
--- @param card Card
--- @param player EntityPlayer
--- @param useFlags UseFlag
Archipelago:AddCallback(ModCallbacks.MC_USE_CARD, function (_, card, player, useFlags)
    local uses = stats.incrementStat(stats.StatKeys.AP_CONSUMABLE_USES)

    -- Done with consumable locations, stop sending them
    if uses > ArchipelagoSlot.CONSUMABLE_COUNT then
        return
    end

    Archipelago:sendLocation(Locations.AP_CONSUMABLE + (uses - 1))
end, Archipelago.SoulOfTheMultiworldType)