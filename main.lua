local mod = RegisterMod("Archipelago", 1)
local json = require("json")
local util = require("util.lua")

mod.ITEMS_DATA = include("item_data")
mod.LOCATIONS_DATA = include("location_data")

AP_MAIN_MOD = mod

ArchipelagoModCallbacks = {
    MC_ARCHIPELAGO_ITEM_RECEIVED = "ARCHIPELAGO_ITEM_RECEIVED",
    MC_ARCHIPELAGO_ITEM_SENT = "ARCHIPELAGO_ITEM_SENT"
}

-- Set location checks, scouts, and death link for the client-server bridge to pick up
function mod:exposeData(location_checks, location_scouts, death_link_reason)
	-- There may be some data that hasn't been picked up yet! We'll need to merge it.
	loadedString = mod:LoadData()
	if loadedString ~= "" then
		old_data = json.decode(loadedString)
	else
		old_data = {
            location_checks = {},
            location_scouts = {},
            died = ""
        }
	end

	-- Any time we expose data, it will ALWAYS be in this format
	local apData = {
		slot_name = ARCHIPELAGO_SLOT,
		seed_name = ARCHIPELAGO_SEED,
		location_checks = old_data.location_checks, -- For location codes we just checked
		location_scouts = old_data.location_scouts, -- For location codes we just scouted
		died = "" -- For deathlink (pending)
	}

    -- Death link
    if death_link_reason and death_link_reason ~= "" then
        apData.died = death_link_reason
    end

    -- New location checks
    if location_checks then
        util.table_concat(apData.location_checks, location_checks)
    end

    -- New location scouts
    if location_scouts then
        util.table_concat(apData.location_scouts, location_scouts)
    end

	mod:SaveData(json.encode(apData))
end

-- Send a location to the server
function mod:sendLocation(location_code)
    self:exposeData({location_code}, nil, nil)
end

-- Send a location scout to the server
function mod:sendLocationScout(location_code)
    self:exposeData(nil, {location_code}, nil)
end

-- Send deathlink to the server
function mod:sendDeathLink(reason)
    self:exposeData(nil, nil, reason)
end

-- Does the effects when you send/receive an item
function mod:showItemGet(itemName, playerName, locationName, isTrap, isReceived)
    local hud = Game():GetHUD()

    if isReceived then
        if playerName ~= ARCHIPELAGO_SLOT then -- Someone else sent us this item
            hud:ShowItemText(itemName, "from " .. playerName .. " has appeared in the basement")
        else -- We got ourselves this item
            hud:ShowItemText(itemName, "has appeared in the basement")
        end
    else -- We got someone else's item
        hud:ShowItemText(itemName, "for " .. playerName .. " has left the basement")
    end

    if isTrap then
        sound = SoundEffect.SOUND_THUMBS_DOWN
    else
        sound = SoundEffect.SOUND_THUMBSUP
    end

    local sfx = SFXManager()
    sfx:Play(sound)
end

-- Draws text to the screen to verify mod setup is ok
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
if ARCHIPELAGO_SEED then
        Isaac.RenderScaledText(ARCHIPELAGO_SLOT, 4, 4, 0.5, 0.5, 1, 1, 1, 0.25)
    else
        Isaac.RenderScaledText("No Archipelago Mod Found", 4, 4, 0.5, 0.5, 1, 0, 0, 1)
    end
end)

-- Remove collectibles and trinkets from the pool if they are locked
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (isContinued)
	mod:exposeData() -- Expose the basic AP data

	local itemPool = Game():GetItemPool()

	-- No archipelago mod? That's not good.
	if not ARCHIPELAGO_SEED then
		return
	end

	local collectiblesRemoved = 0
	local trinketsRemoved = 0
	
	for k, v in pairs(AP_SUPP_MOD.itemStates) do -- Loop through all items
		if not v then -- The item is locked
			if util.string_starts_with(k, "Item") then -- This is a Collectible
				local split = util.string_split(k, "-")
				local id = tonumber(split[2])
				
				itemPool:RemoveCollectible(id)
				
				collectiblesRemoved = collectiblesRemoved + 1
			elseif util.string_starts_with(k, "Trinket") then -- This is a Trinket
				local split = util.string_split(k, "-")
				local id = tonumber(split[2])
				
				itemPool:RemoveTrinket(id)
				
				trinketsRemoved = trinketsRemoved + 1
			end
		end
	end
	
	Isaac.ConsoleOutput("Removed " .. collectiblesRemoved .. " collectibles and " .. trinketsRemoved .. " trinkets\n")
end)

mod:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_ITEM_RECEIVED, function(_, itemName, playerName, locationName, isTrap)
    mod:showItemGet(itemName, playerName, locationName, isTrap, true)
end)

mod:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_ITEM_SENT, function(_, itemName, playerName, locationName, isTrap)
    mod:showItemGet(itemName, playerName, locationName, isTrap, false)
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
    if Input.IsButtonPressed(Keyboard.KEY_B, 0) then
        mod:sendLocation(880)
    end
end)

require("floor_completion")