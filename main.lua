local mod = RegisterMod("Archipelago", 1)
local json = require("json")
local util = require("util.lua")

mod.ITEMS_DATA = require("data/item_data")
mod.LOCATIONS_DATA = require("data/location_data")
mod.ENTITIES_DATA = require("data/entities_data")
mod.BABY_SKIN_DATA = require("data/baby_skin_data")
mod.CHARACTER_DATA = require("data/character_data")
mod.CHALLENGE_DATA = require("data/challenge_data")

-- Fill out the rest of ITEMS_DATA with data we can pull out of it
local codes = {}
for _, code in pairs(mod.ITEMS_DATA.NAME_TO_CODE) do
    codes[#codes + 1] = code
end
table.sort(codes) -- We'd prefer this in order, thanks
mod.ITEMS_DATA.CODES = codes

AP_MAIN_MOD = mod

ArchipelagoModCallbacks = {
    MC_ARCHIPELAGO_ITEM_RECEIVED = "ARCHIPELAGO_ITEM_RECEIVED",
    MC_ARCHIPELAGO_ITEM_SENT = "ARCHIPELAGO_ITEM_SENT",
    MC_ARCHIPELAGO_PICKUP_PICKED = "ARCHIPELAGO_PICKUP_PICKED",
    MC_ARCHIPELAGO_CHEST_OPENED = "ARCHIPELAGO_CHEST_OPENED"
}

-- Set location checks, scouts, and death link for the client-server bridge to pick up
function mod:exposeData(location_checks, location_scouts, death_link_reason)
	-- There may be some data that hasn't been picked up yet! We'll need to merge it.
	local loadedString = mod:LoadData()
    local oldData = {}
	if loadedString ~= "" then
		oldData = json.decode(loadedString)
	else
		oldData = {
            location_checks = {},
            location_scouts = {},
            died = ""
        }
	end

	-- Any time we expose data, it will ALWAYS be in this format
	local apData = {
		slot_name = ARCHIPELAGO_SLOT,
		seed_name = ARCHIPELAGO_SEED,
		location_checks = oldData.location_checks, -- For location codes we just checked
		location_scouts = oldData.location_scouts, -- For location codes we just scouted
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

-- Sends multiple locations to the server
function mod:sendLocations(location_codes)
    self:exposeData(location_codes, nil, nil)
end

-- Send a location scout to the server
function mod:sendLocationScout(location_code)
    self:exposeData(nil, {location_code}, nil)
end

-- Send deathlink to the server
function mod:sendDeathLink(reason)
    self:exposeData(nil, nil, reason)
end

-- Returns true if the item code is considered to be unlocked
function mod:checkUnlocked(code)
    return AP_SUPP_MOD.itemStates[tostring(code)] -- The codes are strings in the table
end

-- Same as above, but with an item's name instead
function mod:checkUnlockedByName(name)
    return AP_SUPP_MOD.itemStates[tostring(mod.ITEMS_DATA.NAME_TO_CODE[name])]
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

    local sound = nil
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
	
    -- Lock collectibles
    for collectibleId, code in pairs(mod.ITEMS_DATA.COLLECTIBLE_ID_TO_CODE) do
        if not mod:checkUnlocked(code) then
            itemPool:RemoveCollectible(collectibleId)
        end
    end

    -- Lock trinkets
    for trinketId, code in pairs(mod.ITEMS_DATA.TRINKET_ID_TO_CODE) do
        if not mod:checkUnlocked(code) then
            itemPool:RemoveTrinket(trinketId)
        end
    end
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

require("pickups")

require("locations/floor_completion")
require("locations/enemy_destruction")
require("locations/completion_marks")
require("locations/donations")
require("locations/challenge_completion")
require("locations/one_offs")

require("items/consumables")
require("items/entities")
require("items/quest")
require("items/floors")
require("items/grid_entities")
require("items/characters")
require("items/curses")

require("tracker/tracker")