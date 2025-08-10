local mod = RegisterMod("Archipelago", 1)
local json = require("json")
local util = require("archipelago.util")

mod.ITEMS_DATA = require("archipelago.data.item_data")
mod.LOCATIONS_DATA = require("archipelago.data.location_data")
mod.ENTITIES_DATA = require("archipelago.data.entities_data")
mod.BABY_SKIN_DATA = require("archipelago.data.baby_skin_data")
mod.CHARACTER_DATA = require("archipelago.data.character_data")
mod.CHALLENGE_DATA = require("archipelago.data.challenge_data")
mod.COLLECTIBLE_TAGS_DATA = require("archipelago.data.collectible_tags")

-- Fill out the rest of ITEMS_DATA with data we can pull out of it
local codes = {}
for _, code in pairs(mod.ITEMS_DATA.NAME_TO_CODE) do
    codes[#codes + 1] = code
end
table.sort(codes) -- We'd prefer this in order, thanks
mod.ITEMS_DATA.CODES = codes

AP_MAIN_MOD = mod
local spawnConfetti = require("archipelago.confetti")

ArchipelagoModCallbacks = {
    MC_ARCHIPELAGO_ITEM_RECEIVED = "ARCHIPELAGO_ITEM_RECEIVED", -- Called when the game receives an item through Archipelago
    MC_ARCHIPELAGO_ITEM_SENT = "ARCHIPELAGO_ITEM_SENT", -- Called when the game sends an item through Archipelago
    MC_ARCHIPELAGO_PICKUP_PICKED = "ARCHIPELAGO_PICKUP_PICKED", -- Called when the player picks up a pickup
    MC_ARCHIPELAGO_CHEST_OPENED = "ARCHIPELAGO_CHEST_OPENED", -- Called when the player opens a chest
    MC_ARCHIPELAGO_PRE_GET_COLLECTIBLE = "ARCHIPELAGO_PRE_GET_COLLECTIBLE", -- Called when the player touches an item pedestal
    MC_ARCHIPELAGO_POST_GET_COLLECTIBLE = "ARCHIPELAGO_POST_GET_COLLECTIBLE" -- Called when the item the player picked up is added to their inventory
}

--- @type table Codes of locations that have already been sent. Used to ensure that we're not incurring superfluous writes
local sentLocations = {}

--- Prints an error to the console and log output.
--- @param text string
--- @param stackTrace boolean|nil Whether to print an entire stack trace, 'true' by default
function mod:Error(text, stackTrace)
    if stackTrace == nil then -- Default parameter value
        stackTrace = true
    end

    if stackTrace and debug then -- Lua debugging, then transform to print a traceback
        text = debug.traceback(text)
    end

    print(text)
    Isaac.DebugString(text)
end

--- Set location checks, scouts, and death link for the client-server bridge to pick up.
--- @param locationChecks table|nil
--- @param locationScouts table|nil
--- @param deathLinkReason string|nil
function mod:exposeData(locationChecks, locationScouts, deathLinkReason)
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
    if deathLinkReason and deathLinkReason ~= "" then
        apData.died = deathLinkReason
    end

    -- New location checks
    if locationChecks then
        util.table_concat(apData.location_checks, locationChecks)
    end

    -- New location scouts
    if locationScouts then
        util.table_concat(apData.location_scouts, locationScouts)
    end

	mod:SaveData(json.encode(apData))
end

--- Send a location to the server.
--- @param locationCode integer
function mod:sendLocation(locationCode)
    if locationCode == nil then
        mod:Error("'nil' location given")
        return false
    end

    self:sendLocations({locationCode})
end

--- Sends multiple locations to the server.
--- @param locationCodes integer[]
function mod:sendLocations(locationCodes)
    -- Filter out any location codes that have already been sent
    local finalCodes = {}
    for _, locationCode in ipairs(locationCodes) do
        if not sentLocations[locationCode] then
            finalCodes[#finalCodes + 1] = locationCode

            -- Make sure we don't try sending this location again later
            sentLocations[locationCode] = true
        end
    end

    if #finalCodes > 0 then
        self:exposeData(finalCodes, nil, nil)
    end
end

--- Send a location scout to the server.
--- @param locationCode integer
function mod:sendLocationScout(locationCode)
    self:exposeData(nil, {locationCode}, nil)
end

--- Send deathlink to the server.
--- @param reason string The reason for the deathlink being triggered
function mod:sendDeathLink(reason)
    self:exposeData(nil, nil, reason)
end

--- 'true' if the item code is considered to be unlocked.
--- @param code integer
--- @return boolean
function mod:checkUnlocked(code)
    if code == nil then -- A nil code was given
        mod:Error("'nil' item code given")
        return false
    end

    if not mod.ITEMS_DATA.CODE_TO_NAME[code] then -- A nonexistant code was given
        mod:Error("No such item code " .. tostring(code))
        return false
    end

    return AP_SUPP_MOD:IsItemUnlocked(tostring(code)) -- The codes are strings in the table
end

--- 'true' if the item name is considered to be unlocked.
--- @param name string
--- @return boolean
function mod:checkUnlockedByName(name)
    local code = tostring(mod.ITEMS_DATA.NAME_TO_CODE[name])

    -- A bad item name was given
    if code == nil then
        mod:Error("No such item named '" .. name .. "'")
        return false
    end

    return AP_SUPP_MOD:IsItemUnlocked(code) -- The codes are strings in the table
end

--- Performs effects when you get an item.
--- @param itemName string The item's name
--- @param playerName string The player that sent the item
--- @param locationName string The location the item came from
--- @param isTrap boolean If the item is considered a trap (a bad item)
--- @param isReceived boolean Whether the item is being sent, or received
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

--- Draws the player's slot name to the screen to better verify that everything is set up correctly.
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
if ARCHIPELAGO_SEED then
        Isaac.RenderScaledText(ARCHIPELAGO_SLOT, 4, 4, 0.5, 0.5, 1, 1, 1, 0.25)
    else
        Isaac.RenderScaledText("No Archipelago Mod Found", 4, 4, 0.5, 0.5, 1, 0, 0, 1)
    end
end)

--- Remove collectibles and trinkets from the pool if they are locked.
--- @param isContinued boolean
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

--- Fired when an item is received from the Archipelago server.
--- @param itemName string
--- @param playerName string
--- @param locationName string
--- @param isTrap boolean
mod:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_ITEM_RECEIVED, function(_, itemName, playerName, locationName, isTrap)
    mod:showItemGet(itemName, playerName, locationName, isTrap, true)

    -- Celebratory confetti (awesome)
    spawnConfetti(math.random(15, 30))
end)

--- Fired when an item is sent to the Archipelago server.
--- @param itemName string
--- @param playerName string
--- @param locationName string
--- @param isTrap boolean
mod:AddCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_ITEM_SENT, function(_, itemName, playerName, locationName, isTrap)
    mod:showItemGet(itemName, playerName, locationName, isTrap, false)
end)

require("archipelago.callbacks")

require("archipelago.locations.floor_completion")
require("archipelago.locations.enemy_destruction")
require("archipelago.locations.completion_marks")
require("archipelago.locations.donations")
require("archipelago.locations.challenge_completion")
require("archipelago.locations.one_offs")

require("archipelago.items.consumables")
require("archipelago.items.entities")
require("archipelago.items.quest")
require("archipelago.items.floors")
require("archipelago.items.grid_entities")
require("archipelago.items.characters")
require("archipelago.items.curses")

require("archipelago.tracker.tracker")