local Locations = AP_MAIN_MOD.LOCATIONS_DATA.LOCATIONS

-- True when Gideon is updated. False when the room changes.
local gideonFlag = false

-- Same thing as gideonFlag, but for Rotgut's first form
local rotgutFlag = false

-- Same as gideonFlag, but for Chimera (unsplit)
local chimeraFlag = false

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

--- Returns the name of an entity based on its type and variant.
--- @param type EntityType
--- @param variant integer
--- @return string
local function typeVariantToName(type, variant)
    return AP_MAIN_MOD.ENTITIES_DATA[tostring(type) .. ":" .. tostring(variant)]
end

--- Tries to grant a location check for defeating this entity.
--- @param name string The name of the defeated entity
--- @param locations table The table of locations to modify
local function defeatLocations(name, locations)
    local locationName = name .. " Defeated"
    local locationID = AP_MAIN_MOD.LOCATIONS_DATA.NAME_TO_CODE[locationName]

    print(locationName)

    -- Ultra Greed defeated as Azazel
    if name == "Ultra Greed" and Isaac.GetPlayer():GetPlayerType() == PlayerTypes.PLAYER_AZAZEL then
        locations[#locations + 1] = Locations.ULTRA_GREED_DEFEATED_AS_AZAZEL
    end

    -- Lamb Defeated in 20 minutes
    if name == "The Lamb" and (Game().TimeCounter / 30 / 60) < 20 then
        locations[#locations + 1] = Locations.THE_LAMB_DEFEATED_LESS_THAN_20_MINUTES
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

--- Modifies the location tables to grant locations for more specific kill conditions.
--- For example, killing Mom's Heart X number of times or killing all 7 sins.
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

    if getKillsFor(killsTable, "Baby Plum") == 10 then -- Baby Plum x10
        locations[#locations + 1] = Locations.BABY_PLUM_DEFEATED_10X
    end

    if getKillsFor(killsTable, "Little Horn") == 20 then -- Little Horn x20
        locations[#locations + 1] = Locations.LITTLE_HORN_DEFEATED_20X
    end

    if getKillsFor(killsTable, "Satan") == 5 then -- Satan x5
        locations[#locations + 1] = Locations.SATAN_DEFEATED_5X
    end

    if getKillsFor(killsTable, "Hush") == 3 then -- Hush x3
        locations[#locations + 1] = Locations.HUSH_DEFEATED_3X
    end

    local isaacKills = getKillsFor(killsTable, "Isaac")

    -- Isaac kills
    if isaacKills == 5 then
        locations[#locations + 1] = Locations.ISAAC_DEFEATED_5X
    elseif isaacKills == 10 then
        locations[#locations + 1] = Locations.ISAAC_DEFEATED_10X
    end

    local famineKills = getKillsFor(killsTable, "Famine")
    local pestilenceKills = getKillsFor(killsTable, "Pestilence")
    local warKills = getKillsFor(killsTable, "War")
    local deathKills = getKillsFor(killsTable, "Death")
    local conquestKills = getKillsFor(killsTable, "Conquest")

    -- Any Harbinger killed
    if famineKills > 0 or pestilenceKills > 0 or warKills > 0 or deathKills > 0 or conquestKills > 0 then
        locations[#locations + 1] = Locations.ANY_HARBINGER_DEFEATED
    end

    -- All Harbingers killed
    if famineKills > 0 and pestilenceKills > 0 and warKills > 0 and deathKills > 0 and conquestKills > 0 then
        locations[#locations + 1] = Locations.ALL_5_HARBINGERS_DEFEATED
    end

    local blueBabyKills = getKillsFor(killsTable, "???")
    local lambKills = getKillsFor(killsTable, "The Lamb")

    -- ??? and Lamb killed
    if blueBabyKills > 0 and lambKills > 0 then
        locations[#locations + 1] = Locations.BLUEBABY_AND_THE_LAMB_DEFEATED
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
        locations[#locations + 1] = Locations.ALL_7_SINS_DEFEATED
    end

    -- Angels killed
    local angelKills = getKillsFor(killsTable, "Gabriel") + getKillsFor(killsTable, "Uriel")
    if angelKills == 10 then
        locations[#locations + 1] = Locations.ANGEL_DEFEATED_10X
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
        locations[#locations + 1] = Locations.DEFEAT_ALL_BOSSES_IN_BASEMENT
    end

    if allBossesKilled(CavesBosses) then
        locations[#locations + 1] = Locations.DEFEAT_ALL_BOSSES_IN_CAVES
    end

    if allBossesKilled(DepthsBosses) then
        locations[#locations + 1] = Locations.DEFEAT_ALL_BOSSES_IN_DEPTHS
    end

    if allBossesKilled(DownpourBosses) then
        locations[#locations + 1] = Locations.DEFEAT_ALL_BOSSES_IN_DOWNPOUR
    end

    if allBossesKilled(MinesBosses) then
        locations[#locations + 1] = Locations.DEFEAT_ALL_BOSSES_IN_MINES
    end

    if allBossesKilled(MausoleumBosses) then
        locations[#locations + 1] = Locations.DEFEAT_ALL_BOSSES_IN_MAUSOLEUM
    end

    -- Kill 20 portals
    if getKillsFor(killsTable, "Portal") == 20 then
        locations[#locations + 1] = Locations.PORTAL_DEFEATED_20X
    end
end

-- Enemies we've slain this room
local slain = {}

-- Awards locations for all enemies slain in the room.
local function awardChecksForSlainEnemies()
    local kills = getAllKills() -- Load all stats
    local locations = {}

    -- Grant locations for defeating foes, and count their kills
    for _, v in ipairs(slain) do
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

    slain = {} -- Flush the slain table
end

--- Handles counting slain enemies.
--- @param entity Entity
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    local type = entity.Type
    local variant = entity.Variant

    -- Mark enemies that we've slain in this room.
    -- When the room is completed, checks will be granted and this will be flushed
    slain[#slain + 1] = {type = type, variant = variant}

    -- Dogma doesn't "clear" the room when killed, so we'll need to immediately check for him
    if type == EntityType.ENTITY_DOGMA and variant == 2 then -- "Angel" variant
        awardChecksForSlainEnemies()
    end
end)

--- Fired when the room is cleared, to grant locations for all enemies that were defeated in the room.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function ()
    awardChecksForSlainEnemies()
end)

--- Flushes the 'seen' table when entering a new room, in case the player escapes a fight and doesn't actually win.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    slain = {}
    gideonFlag = false
    rotgutFlag = false
    chimeraFlag = false
end)

--- Used to handle "slaying" Great Gideon. Since he is normally not killed, he is considered "slain" as soon as
--- he appears.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_)
    if gideonFlag then
        return
    end

    gideonFlag = true
    slain[#slain + 1] = {type = EntityType.ENTITY_GIDEON, variant = 0}
end, EntityType.ENTITY_GIDEON)

--- Used to handle slaying Rotgut. Because of his room-changing mechanic, and that he's already dying by
--- the time the player is returned to the boss room, this is used to set that he's been slain.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_)
    if rotgutFlag then
        return
    end

    rotgutFlag = true
    slain[#slain + 1] = {type = EntityType.ENTITY_ROTGUT, variant = 0}
end, EntityType.ENTITY_ROTGUT)

--- Used to handle slaying Chimera. Because he can split in half, and becomes two separate NPCs without dying,
--- he needs to be subject to counting as "slain" the moment he appears.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_)
    if chimeraFlag then
        return
    end

    chimeraFlag = true
    slain[#slain + 1] = {type = EntityType.ENTITY_CHIMERA, variant = 0}
end, EntityType.ENTITY_CHIMERA)

local babyPlumSpared = false -- To debounce the location send (so it's not every frame)

--- Handles sparing Baby Plum.
--- @param npc Entity
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, npc)
    if babyPlumSpared then
        return
    end

    if not npc:GetSprite():IsPlaying("Leave") then
        return
    end

    babyPlumSpared = true
    AP_MAIN_MOD:sendLocation(Locations.BABY_PLUM_SPARED)
end, EntityType.ENTITY_BABY_PLUM)