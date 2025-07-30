local export = {}

-- Names of each character. This is used to look up their locations for completing certain bosses or floors
export.playerTypeNames = {
    [PlayerType.PLAYER_POSSESSOR] = "Possessor",
    [PlayerType.PLAYER_ISAAC] = "Isaac",
    [PlayerType.PLAYER_MAGDALENE] = "Magdalene",
    [PlayerType.PLAYER_CAIN] = "Cain",
    [PlayerType.PLAYER_JUDAS] = "Judas",
    [PlayerType.PLAYER_BLUEBABY] = "???",
    [PlayerType.PLAYER_EVE] = "Eve",
    [PlayerType.PLAYER_SAMSON] = "Samson",
    [PlayerType.PLAYER_AZAZEL] = "Azazel",
    [PlayerType.PLAYER_LAZARUS] = "Lazarus",
    [PlayerType.PLAYER_EDEN] = "Eden",
    [PlayerType.PLAYER_THELOST] = "Lost",
    [PlayerType.PLAYER_LAZARUS2] = "Lazarus",
    [PlayerType.PLAYER_BLACKJUDAS] = "Judas",
    [PlayerType.PLAYER_LILITH] = "Lilith",
    [PlayerType.PLAYER_KEEPER] = "Keeper",
    [PlayerType.PLAYER_APOLLYON] = "Apollyon",
    [PlayerType.PLAYER_THEFORGOTTEN] = "Forgotten",
    [PlayerType.PLAYER_THESOUL] = "Forgotten",
    [PlayerType.PLAYER_BETHANY] = "Bethany",
    [PlayerType.PLAYER_JACOB] = "Jacob and Esau",
    [PlayerType.PLAYER_ESAU] = "Jacob and Esau",

    -- Tainted
    [PlayerType.PLAYER_ISAAC_B] = "Tainted Isaac",
    [PlayerType.PLAYER_MAGDALENE_B] = "Tainted Magdalene",
    [PlayerType.PLAYER_CAIN_B] = "Tainted Cain",
    [PlayerType.PLAYER_JUDAS_B] = "Tainted Judas",
    [PlayerType.PLAYER_BLUEBABY_B] = "Tainted ???",
    [PlayerType.PLAYER_EVE_B] = "Tainted Eve",
    [PlayerType.PLAYER_SAMSON_B] = "Tainted Samson",
    [PlayerType.PLAYER_AZAZEL_B] = "Tainted Azazel",
    [PlayerType.PLAYER_LAZARUS_B] = "Tainted Lazarus",
    [PlayerType.PLAYER_EDEN_B] = "Tainted Eden",
    [PlayerType.PLAYER_THELOST_B] = "Tainted Lost",
    [PlayerType.PLAYER_LILITH_B] = "Tainted Lilith",
    [PlayerType.PLAYER_KEEPER_B] = "Tainted Keeper",
    [PlayerType.PLAYER_APOLLYON_B] = "Tainted Apollyon",
    [PlayerType.PLAYER_THEFORGOTTEN_B] = "Tainted Forgotten",
    [PlayerType.PLAYER_BETHANY_B] = "Tainted Bethany",
    [PlayerType.PLAYER_JACOB_B] = "Tainted Jacob",
    [PlayerType.PLAYER_LAZARUS2_B] = "Tainted Lazarus",
    [PlayerType.PLAYER_JACOB2_B] = "Tainted Jacob",
    [PlayerType.PLAYER_THESOUL_B] = "Tainted Forgotten"
}

export.taintedCharacters = {
    [PlayerType.PLAYER_ISAAC_B] = true,
    [PlayerType.PLAYER_MAGDALENE_B] = true,
    [PlayerType.PLAYER_CAIN_B] = true,
    [PlayerType.PLAYER_JUDAS_B] = true,
    [PlayerType.PLAYER_BLUEBABY_B] = true,
    [PlayerType.PLAYER_EVE_B] = true,
    [PlayerType.PLAYER_SAMSON_B] = true,
    [PlayerType.PLAYER_AZAZEL_B] = true,
    [PlayerType.PLAYER_LAZARUS_B] = true,
    [PlayerType.PLAYER_EDEN_B] = true,
    [PlayerType.PLAYER_THELOST_B] = true,
    [PlayerType.PLAYER_LILITH_B] = true,
    [PlayerType.PLAYER_KEEPER_B] = true,
    [PlayerType.PLAYER_APOLLYON_B] = true,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = true,
    [PlayerType.PLAYER_BETHANY_B] = true,
    [PlayerType.PLAYER_JACOB_B] = true,
    [PlayerType.PLAYER_LAZARUS2_B] = true,
    [PlayerType.PLAYER_JACOB2_B] = true,
    [PlayerType.PLAYER_THESOUL_B] = true
}

function export.get_character_name ()
    return export.playerTypeNames[Isaac.GetPlayer():GetPlayerType()]
end

function export.is_character_tainted ()
    return export.taintedCharacters[Isaac.GetPlayer():GetPlayerType()] ~= nil
end

-- Picks a random value from the table
function export.random_from_table (rng, table)
    local keys = export.table_keys(table)
    return table[rng:RandomInt(#keys) + 1]
end

-- Picks a random value from the array
function export.random_from_array (rng, table)
    return table[rng:RandomInt(#table) + 1]
end

-- Shuffles a table in-place
function export.shuffle_table(rng, table)
    for i = #table, 2, -1 do
        local j = rng:RandomInt(i) + 1
        table[i], table[j] = table[j], table[i]
    end
end

-- Merges all arrays given into one array
function export.merge_arrays (array_of_arrays)
    local collection = {}
    for _, array in ipairs(array_of_arrays) do
        for _, value in ipairs(array) do
            collection[#collection + 1] = value
        end
    end

    return collection
end

-- Gets an array of table keys
function export.table_keys(table)
    local keys = {}

    for key, _ in pairs(table) do
        keys[#keys + 1] = key
    end

    return keys
end

-- http://lua-users.org/wiki/StringRecipes
function export.string_starts_with (str, starts_with)
	return str:sub(1, #starts_with) == starts_with
end

function export.string_ends_with (str, ends_with)
	return ends_with == "" or str:sub(-#ends_with) == ends_with
end

function export.string_split (str, delimiter)
	local output = {}
	local i = 1
	
	for match in string.gmatch(str, '([^'..delimiter..']+)') do
		output[i] = match
		i = i + 1
	end
	
	return output
end

function export.table_concat(to_table, from_table)
    for _, v in ipairs(from_table) do
        table.insert(to_table, v)
    end
end

function export.table_tostring(table)
    local str = ""
    for key, value in pairs(table) do
        str = str .. key .. ": " .. value .. ", "
    end

    return "{" .. string.sub(str, 1, #str - 2) .. "}"
end

function export.array_tostring(array)
    local str = ""
    for key, value in ipairs(array) do
        str = str .. key .. ": " .. value .. ", "
    end

    return "[" .. string.sub(str, 1, #str - 2) .. "]"
end

function export.chunk_array(tab, count)
    local out = {}

    for i = 1, #tab, count do
        out[#out + 1] = {table.unpack(tab, i, math.min(#tab, i + count - 1))}
    end

    return out
end

function export.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

-- Returns the table, but the keys and values are swapped
function export.invert_table(tab)
    local newTable = {}
    for key, value in pairs(tab) do
        newTable[value] = key
    end

    return newTable
end

-- Creates a shallow copy of the table
function export.shallow_copy_table(tab)
    local out = {}
    for k, v in pairs(tab) do
        out[k] = v
    end

    return out
end

-- Creates an RNG object, by seeding it with the run's seed
function export.getRNG()
    local startSeed = Game():GetSeeds():GetStartSeed()
    local rng = RNG()
    rng:SetSeed(startSeed, 35)

    return rng
end

-- 'True' if the room is the final boss room of the floor.
-- This is helpful in case Curse of the Labyrinth is on.
function export.isFinalBossRoomOfFloor(room)
    if room:GetType() ~= RoomType.ROOM_BOSS then -- This isn't even a boss room
        return false
    end

    -- In The Void, the only 2x2 boss room is Delirium's room
    local stage = Game():GetLevel():GetStage()
    if room:GetRoomShape() == RoomShape.ROOMSHAPE_2x2 and stage == LevelStage.STAGE7 then
        return true
    end

    -- In Blue Womb, there can only ever be one boss
    if stage == LevelStage.STAGE4_3 then
        return true
    end

    -- Count the number of doors, in case of curse of labyrinth
    local regularDoors = 0
    local bossDoors = 0
    for i = 0, DoorSlot.NUM_DOOR_SLOTS, 1 do
        local door = room:GetDoor(i)

        if door then
            -- door:IsRoomType() is UNRELIABLE and USELESS for this, I GUESS
            if door.TargetRoomType == RoomType.ROOM_DEFAULT then
                regularDoors = regularDoors + 1
            elseif door.TargetRoomType == RoomType.ROOM_BOSS then
                bossDoors = bossDoors + 1
            end
        end
    end

    -- On curse of the labyrinth, this is the first boss room
    if bossDoors == 1 and regularDoors == 1 then
        return false
    end

    return true
end

-- Returns which stage this is.
-- For labyrinth stages, this will be the latter half of the chapter (1_1 -> 1_2)
function export.getEffectiveStage(level)
    local isLabyrinth = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH > 0
    local stage = level:GetStage()

    -- All levels from 5 and on (sheol/cathedral) can't have Labyrinth
    if stage > LevelStage.STAGE5 then
        return stage
    end

    -- On labyrinth stages, it's only the first half, so stage + 1
    if isLabyrinth then
        return stage + 1
    end

    return stage
end

-- Removes the alt path door in boss rooms, and the ascent door in Depths
function export.removeSecretExit(room)
    for slot = 0, DoorSlot.NUM_DOOR_SLOTS, 1 do
        local door = room:GetDoor(slot)

        if door and door.TargetRoomType == RoomType.ROOM_SECRET_EXIT then
            room:RemoveDoor(slot)
        end
    end
end

local itemConfig = Isaac.GetItemConfig()

-- Adds a collectible's costume to the player
function export.addCostumeToPlayer(player, collectibleType, addToTwin)
    local configItem = itemConfig:GetCollectible(collectibleType)
    player:AddCostume(configItem)

    if addToTwin then
        local twin = player:GetOtherTwin()

        if twin and twin ~= player then -- Sometimes they are the same???
            twin:AddCostume(configItem)
        end
    end
end

return export