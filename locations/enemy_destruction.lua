local BasementBosses = {
    "Dingle", "The Duke of Flies", "Gemini", "Larry Jr.", "Monstro", "Gurglings", "Famine"
}

local CavesBosses = {
    "Chub", "Gurdy", "Gurdy Jr.", "Mega Fatty", "Mega Maw", "Peep", "Pestilence"
}

local DepthsBosses = {
    "The Cage", "The Gate", "Monstro II", "Loki", "The Adversary", "War"
}

local DownpourBosses = {
    "Lil Blub", "Wormwood", "The Rainmaker", "Min-Min"
}

local MinesBosses = {
    "Reap Creep", "Tuff Twins", "Hornfel", "Great Gideon"
}

local MausoleumBosses = {
    "The Siren", "The Heretic"
}

local function typeVariantToName(type, variant)
    return AP_MAIN_MOD.ENTITIES_DATA[tostring(type) .. ":" .. tostring(variant)]
end

--- Tries to grant a location check for defeating this entity.
---@param name string The name of the defeated entity
---@param locations table The table of locations to modify
local function defeatLocations(name, locations)
    local locationName = name .. " Defeated"
    local locationID = AP_MAIN_MOD.LOCATIONS_DATA[locationName]

    -- Ultra Greed defeated as Azazel
    if name == "Ultra Greed" and Isaac.GetPlayer():GetPlayerType() == PlayerTypes.PLAYER_AZAZEL then
        locations[#locations + 1] = 363
    end

    -- Lamb Defeated in 20 minutes
    if name == "The Lamb" and (Game().BossRushParTime / 60 / 60) < 20 then
        locations[#locations + 1] = 360
    end

    -- Mom's Heart defeated as Lazarus w/ no deaths
    if (name == "Mom's Heart" or name == "It Lives") and Isaac.GetPlayer():GetPlayerType() == PlayerTypes.PLAYER_LAZARUS and not AP_SUPP_MOD:LoadKey("died_this_run", false) then
        locations[#locations + 1] = 358
    end

    if locationID ~= nil then
        locations[#locations + 1] = locationID
    end
end

-- Increments the amount of kills on the given enemy, and returns the new amount
local function incrementKill(killsTable, name)
    local count = killsTable[name] or 0

    count = count + 1

    killsTable[name] = count
    return count
end

-- Gets the number of times the given enemy was killed
local function getKillsFor(killsTable, name)
    local count = killsTable[name]

    if count == nil then
        return 0
    end

    return count
end

-- Loads the entire enemy kill stats from the save file
local function getAllKills()
    return AP_SUPP_MOD:LoadKey("kills", {})
end

-- Sets enemy kill stats to the save file
local function setKills(killsTable)
    AP_SUPP_MOD:SaveKey("kills", killsTable)
end

--- @param killsTable table The table of kills
--- @param locations table The table of locations to modify
local function otherKillLocations(killsTable, locations)
    -- Mom's Heart kills
    local heartKills = getKillsFor(killsTable, "Mom's Heart")
    local livesKills = getKillsFor(killsTable, "It Lives")
    local bothKills = heartKills + livesKills

    local momsHeartKillLocations = {
        [2] = 348,
        [3] = 349,
        [4] = 350,
        [5] = 351,
        [6] = 352,
        [7] = 353,
        [8] = 354,
        [9] = 355,
        [10] = 356,
        [11] = 357
    }

    -- We use a combination of both mom's heart AND it lives, since mom's heart is potentially replaced
    if momsHeartKillLocations[bothKills] ~= nil then
        locations[#locations + 1] = momsHeartKillLocations[bothKills]
    end

    -- It Lives kills
    if livesKills == 16 then
        locations[#locations + 1] = 370
    elseif livesKills == 21 then
        locations[#locations + 1] = 371
    elseif livesKills == 30 then
        locations[#locations + 1] = 372
    end

    if getKillsFor(killsTable, "Baby Plum") == 10 then
        locations[#locations + 1] = 340
    end

    if getKillsFor(killsTable, "Little Horn") == 10 then
        locations[#locations + 1] = 373
    end

    if getKillsFor(killsTable, "Satan") == 10 then
        locations[#locations + 1] = 359
    end

    if getKillsFor(killsTable, "Hush") == 3 then
        locations[#locations + 1] = 347
    end

    local isaacKills = getKillsFor(killsTable, "Isaac")

    -- Isaac kills
    if isaacKills == 5 then
        locations[#locations + 1] = 361
    elseif isaacKills == 10 then
        locations[#locations + 1] = 362
    end

    local famineKills = getKillsFor(killsTable, "Famine")
    local pestilenceKills = getKillsFor(killsTable, "Pestilence")
    local warKills = getKillsFor(killsTable, "War")
    local deathKills = getKillsFor(killsTable, "Death")
    local conquestKills = getKillsFor(killsTable, "Conquest")

    -- Any Harbinger killed
    if famineKills > 0 or pestilenceKills > 0 or warKills > 0 or deathKills > 0 or conquestKills > 0 then
        locations[#locations + 1] = 343
    end

    -- All Harbingers killed
    if famineKills > 0 and pestilenceKills > 0 and warKills > 0 and deathKills > 0 and conquestKills > 0 then
        locations[#locations + 1] = 344
    end

    local blueBabyKills = getKillsFor(killsTable, "???")
    local lambKills = getKillsFor(killsTable, "The Lamb")

    -- ??? and Lamb killed
    if blueBabyKills > 0 and lambKills > 0 then
        locations[#locations + 1] = 346
    end

    -- All sins defeated
    local killedAllSins = true
    local function getSinKills (name)
        return getKillsFor(killsTable, name) + getKillsFor(killsTable, "Super " .. name)
    end

    for _, v in ipairs({"Greed", "Envy", "Lust", "Sloth", "Wrath", "Pride", "Gluttony"}) do
        if getSinKills(v) == 0 then
            killedAllSins = false
            break
        end
    end

    if killedAllSins then
        locations[#locations + 1] = 342
    end

    -- Angels killed
    local angelKills = getKillsFor(killsTable, "Gabriel") + getKillsFor(killsTable, "Uriel")
    if angelKills == 10 then
        locations[#locations + 1] = 345
    end

    -- 'All Bosses' killed in area
    local function allBossesKilled (bossTable)
        for _, name in ipairs(bossTable) do
            if getKillsFor(killsTable, name) == 0 then
                return false
            end
        end

        return true
    end

    if allBossesKilled(BasementBosses) then
        locations[#locations + 1] = 364
    end

    if allBossesKilled(CavesBosses) then
        locations[#locations + 1] = 365
    end

    if allBossesKilled(DepthsBosses) then
        locations[#locations + 1] = 366
    end

    if allBossesKilled(DownpourBosses) then
        locations[#locations + 1] = 367
    end

    if allBossesKilled(MinesBosses) then
        locations[#locations + 1] = 368
    end

    if allBossesKilled(MausoleumBosses) then
        locations[#locations + 1] = 369
    end

    -- Kill 20 portals
    if getKillsFor(killsTable, "Portal") == 20 then
        locations[#locations + 1] = 481
    end
end

-- Enemies we've seen this room
local seen = {}

-- Handles "seeing" enemies (that we have defeated!)
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    local type = entity.Type
    local variant = entity.Variant

    -- For Lazarus @ Mom's Heart (No Deaths)
    if type == EntityType.ENTITY_PLAYER then
        AP_SUPP_MOD:SaveKey("died_this_run", true)
    end

    -- Mark enemies that we've "seen" (read: killed) in this room.
    -- When the room is completed, checks will be granted and this will be flushed
    seen[#seen + 1] = {type = type, variant = variant}
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function ()
    local kills = getAllKills() -- Load all stats
    local locations = {}

    -- Grant locations for defeating foes, and count their kills
    for _, v in ipairs(seen) do
        local name = typeVariantToName(v.type, v.variant)

        if name ~= nil then
            incrementKill(kills, name)
            defeatLocations(name, locations) -- Attempt to grant defeat locations
        end
    end

    -- Check for locations like "kill X boss Y times"
    otherKillLocations(kills, locations)

    -- Grant locations
    if #locations > 0 then
        AP_MAIN_MOD:sendLocations(locations)
    end

    setKills(kills) -- Save all stats

    seen = {} -- Flush the seen table
end)

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    seen = {} -- Flush seen table, in case the player escapes a fight and doesn't actually win
end)

-- Used to track if the player has died this run (for Lazarus @ Mom's Heart (No Deaths))
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    if continued then -- Only reset the 'died this run' state when a new game begins
        return
    end

    AP_SUPP_MOD.SaveKey("died_this_run", false)
end)

-- Handles sparing Baby Plum
local babyPlumSpared = false -- To debounce the location send (so it's not every frame)
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, npc)
    if babyPlumSpared then
        return
    end

    if not npc:GetSprite():IsPlaying("Leave") then
        return
    end

    babyPlumSpared = true
    AP_MAIN_MOD:sendLocation(341)
end, EntityType.ENTITY_BABY_PLUM)