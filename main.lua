local Mod = RegisterMod("Archipelago", 1)
local json = require("json")
local util = require("archipelago.util")

Mod.ITEMS_DATA = require("archipelago.data.item_data")
Mod.LOCATIONS_DATA = require("archipelago.data.location_data")
Mod.ENTITIES_DATA = require("archipelago.data.entities_data")
Mod.BABY_SKIN_DATA = require("archipelago.data.baby_skin_data")
Mod.CHARACTER_DATA = require("archipelago.data.character_data")
Mod.CHALLENGE_DATA = require("archipelago.data.challenge_data")
Mod.COLLECTIBLE_TAGS_DATA = require("archipelago.data.collectible_tags")
Mod.CARD_DATA = require("archipelago.data.consumable_data")
Mod.FORTUNES = require("archipelago.data.fortunes")

Mod.Callbacks = {
    MC_ARCHIPELAGO_ITEM_RECEIVED = "ARCHIPELAGO_ITEM_RECEIVED", -- Called when the game receives an item through Archipelago
    MC_ARCHIPELAGO_ITEM_SENT = "ARCHIPELAGO_ITEM_SENT", -- Called when the game sends an item through Archipelago
    MC_ARCHIPELAGO_PICKUP_PICKED = "ARCHIPELAGO_PICKUP_PICKED", -- Called when the player picks up a pickup
    MC_ARCHIPELAGO_CHEST_OPENED = "ARCHIPELAGO_CHEST_OPENED", -- Called when the player opens a chest
    MC_ARCHIPELAGO_PRE_GET_COLLECTIBLE = "ARCHIPELAGO_PRE_GET_COLLECTIBLE", -- Called when the player touches an item pedestal
    MC_ARCHIPELAGO_POST_GET_COLLECTIBLE = "ARCHIPELAGO_POST_GET_COLLECTIBLE", -- Called when the item the player picked up is added to their inventory
    MC_ARCHIPELAGO_POST_FLOOR_CLEARED = "ARCHIPELAGO_POST_FLOOR_CLEARED", -- Called when the boss of the floor is cleared
    MC_ARCHIPELAGO_POST_CHAPTER_CLEARED = "ARCHIPELAGO_POST_CHAPTER_CLEARED", -- Called when the chapter is cleared
    MC_ARCHIPELAGO_PRE_SLOT_KILLED = "ARCHIPELAGO_PRE_SLOT_KILLED", -- Called just before a slot machine or beggar dies from an explosion
    MC_ARCHIPELAGO_SLOT_GAME_END = "ARCHIPELAGO_SLOT_GAME_END", -- Called when a slot machine finishes playing, the player selects a shell from a shell game, or a beggar pays out
    MC_ARCHIPELAGO_BEGGAR_COLLECTIBLE_PAYOUT = "ARCHIPELAGO_BEGGAR_COLLECTIBLE_PAYOUT", -- Called when a beggar pays out a collectible and disappears
    MC_ARCHIPELAGO_GRID_ENTITY_STATE_CHANGED = "ARCHIPELAGO_GRID_ENTITY_STATE_CHANGED", -- Called when a grid entity's state is changed
    MC_ARCHIPELAGO_FORTUNE_TELLER_FORTUNE = "ARCHIPELAGO_FORTUNE_TELLER_FORTUNE", -- Called when a fortune teller machine or fortune cookie gives a fortune
    MC_ARCHIPELAGO_BED_SLEEP = "ARCHIPELAGO_BED_SLEEP", -- Called when the player sleeps in a bed
    MC_ARCHIPELAGO_MONEY_SPENT = "ARCHIPELAGO_MONEY_SPENT" -- Called when money is subtracted from the player
}

Mod.util = util
Mod.json = json
Mod.game = Game()
Mod.room = function () return Mod.game:GetRoom() end
Mod.level = function () return Mod.game:GetLevel() end
Mod.stats = require("archipelago.stats")
Mod.spawnConfetti = require("archipelago.confetti")
Mod.sfxManager = SFXManager()
Mod.hud = Mod.game:GetHUD()

local teamMeat12Font = Font()
teamMeat12Font:Load("font/teammeatfont12.fnt")

local teamMeat10Font = Font()
teamMeat10Font:Load("font/teammeatfont10.fnt")

local terminusFont = Font()
terminusFont:Load("font/terminus.fnt")

Mod.fonts = {
    TeamMeat12 = teamMeat12Font,
    TeamMeat10 = teamMeat10Font,
    Terminus = terminusFont
}

-- Fill out the rest of ITEMS_DATA with data we can pull out of it
local codes = {}
for _, code in pairs(Mod.ITEMS_DATA.NAME_TO_CODE) do
    codes[#codes + 1] = code
end
table.sort(codes) -- We'd prefer this in order, thanks
Mod.ITEMS_DATA.CODES = codes

--- Global var for the mod
Archipelago = Mod

--- @type table Codes of locations that have already been sent. Used to ensure that we're not incurring superfluous writes
local sentLocations = {}

--- Set location checks, scouts, and death link for the client-server bridge to pick up.
--- @param locationChecks table|nil
--- @param locationScouts table|nil
--- @param deathLinkReason string|nil
function Mod:exposeData(locationChecks, locationScouts, deathLinkReason)
	-- There may be some data that hasn't been picked up yet! We'll need to merge it.
	local loadedString = Mod:LoadData()
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

    local locationData = AP_SUPP_MOD:LoadKey("location_data", {sent = {}, scouted = {}})

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
        apData.location_checks = util.concatArrays({apData.location_checks, locationChecks})

        -- Mark that we have sent this location (it is complete)
        for _, code in ipairs(apData.location_checks) do
            locationData.sent[code] = true
        end
    end

    -- New location scouts
    if locationScouts then
        apData.location_scouts = util.concatArrays({apData.location_scouts, locationScouts})

        -- Mark that we have scout this location
        for _, code in ipairs(apData.location_checks) do
            locationData.scouted[code] = true
        end
    end

	Mod:SaveData(json.encode(apData))
    AP_SUPP_MOD:SaveKey("location_data", locationData)
end

--- Send a location to the server.
--- @param location Location|string
function Mod:sendLocation(location)
    local locationCode = nil
    if type(location) == "string" then -- Convert location name string to location code
        locationCode = Archipelago.LOCATIONS_DATA.NAME_TO_CODE[location]
    else
        locationCode = location
    end

    if locationCode == nil then
        util.Error("'nil' location given ('" .. tostring(location) .. "')")
        return false
    end

    self:sendLocations({locationCode})
end

--- Sends multiple locations to the server.
--- @param locationCodes integer[]
function Mod:sendLocations(locationCodes)
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
function Mod:sendLocationScout(locationCode)
    self:exposeData(nil, {locationCode}, nil)
end

--- Send deathlink to the server.
--- @param reason string The reason for the deathlink being triggered
function Mod:sendDeathLink(reason)
    self:exposeData(nil, nil, reason)
end

--- 'true' if the item code is considered to be unlocked.
--- @param code integer
--- @return boolean
function Mod:checkUnlocked(code)
    if code == nil then -- A nil code was given
        util.Error("'nil' item code given")
        return false
    end

    if not Mod.ITEMS_DATA.CODE_TO_NAME[code] then -- A nonexistant code was given
        util.Error("No such item code " .. tostring(code))
        return false
    end

    return AP_SUPP_MOD:IsItemUnlocked(tostring(code)) -- The codes are strings in the table
end

--- 'true' if the item name is considered to be unlocked.
--- @param name string
--- @return boolean
function Mod:checkUnlockedByName(name)
    local code = tostring(Mod.ITEMS_DATA.NAME_TO_CODE[name])

    -- A bad item name was given
    if code == nil then
        util.Error("No such item named '" .. name .. "'")
        return false
    end

    return AP_SUPP_MOD:IsItemUnlocked(code) -- The codes are strings in the table
end

--- 'true' if the location code has already been sent.
--- @param code integer
--- @return boolean
function Mod:checkLocationSent(code)
    return AP_SUPP_MOD:LoadKey("location_data", {sent = {}, scouted = {}}).sent[code] ~= nil
end

--- 'true' if the location code has already been scouted.
--- @param code integer
--- @return boolean
function Mod:checkLocationScouted(code)
    return AP_SUPP_MOD:LoadKey("location_data", {sent = {}, scouted = {}}).scouted[code] ~= nil
end

--- Performs effects when you get an item.
--- @param itemName string The item's name
--- @param playerName string The player that sent the item
--- @param locationName string The location the item came from
--- @param isTrap boolean If the item is considered a trap (a bad item)
--- @param isReceived boolean Whether the item is being sent, or received
function Mod:showItemGet(itemName, playerName, locationName, isTrap, isReceived)
    local hud = Archipelago.hud

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

    Mod.sfxManager:Play(sound)
end

--- Draws the player's slot name to the screen to better verify that everything is set up correctly.
Mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
if ARCHIPELAGO_SEED then
        Isaac.RenderScaledText(ARCHIPELAGO_SLOT, 4, 4, 0.5, 0.5, 1, 1, 1, 0.25)
    else
        Isaac.RenderScaledText("No Archipelago Mod Found", 4, 4, 0.5, 0.5, 1, 0, 0, 1)
    end
end)

--- Remove collectibles and trinkets from the pool if they are locked.
--- @param isContinued boolean
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (isContinued)
	Mod:exposeData() -- Expose the basic AP data

	local itemPool = Archipelago.game:GetItemPool()

	-- No archipelago mod? That's not good.
	if not ARCHIPELAGO_SEED then
		return
	end
	
    -- Lock collectibles
    for collectibleId, code in pairs(Mod.ITEMS_DATA.COLLECTIBLE_ID_TO_CODE) do
        if not Mod:checkUnlocked(code) then
            itemPool:RemoveCollectible(collectibleId)
        end
    end

    -- Lock trinkets
    for trinketId, code in pairs(Mod.ITEMS_DATA.TRINKET_ID_TO_CODE) do
        if not Mod:checkUnlocked(code) then
            itemPool:RemoveTrinket(trinketId)
        end
    end
end)

--- Fired when an item is received from the Archipelago server.
--- @param itemName string
--- @param playerName string
--- @param locationName string
--- @param isTrap boolean
Mod:AddCallback(Archipelago.Callbacks.MC_ARCHIPELAGO_ITEM_RECEIVED, function(_, itemName, playerName, locationName, isTrap)
    Mod:showItemGet(itemName, playerName, locationName, isTrap, true)

    -- Celebratory confetti (awesome)
    Mod.spawnConfetti(math.random(15, 30))
end)

--- Fired when an item is sent to the Archipelago server.
--- @param itemName string
--- @param playerName string
--- @param locationName string
--- @param isTrap boolean
Mod:AddCallback(Archipelago.Callbacks.MC_ARCHIPELAGO_ITEM_SENT, function(_, itemName, playerName, locationName, isTrap)
    Mod:showItemGet(itemName, playerName, locationName, isTrap, false)
end)

require("archipelago.callbacks")

require("archipelago.locations.floor_completion")
require("archipelago.locations.enemy_destruction")
require("archipelago.locations.completion_marks")
require("archipelago.locations.donations")
require("archipelago.locations.challenge_completion")
require("archipelago.locations.one_offs")
require("archipelago.locations.consumable")

require("archipelago.items.consumables")
require("archipelago.items.entities")
require("archipelago.items.quest")
require("archipelago.items.floors")
require("archipelago.items.grid_entities")
require("archipelago.items.characters")
require("archipelago.items.curses")
require("archipelago.items.planetarium")
require("archipelago.items.starting_items")

require("archipelago.tracker.tracker")
require("archipelago.fortunes")