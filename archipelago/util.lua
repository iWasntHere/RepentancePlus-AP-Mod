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

export.taintedCounterpartNames = {
    [PlayerType.PLAYER_ISAAC] = "Tainted Isaac",
    [PlayerType.PLAYER_MAGDALENE] = "Tainted Magdalene",
    [PlayerType.PLAYER_CAIN] = "Tainted Cain",
    [PlayerType.PLAYER_JUDAS] = "Tainted Judas",
    [PlayerType.PLAYER_BLUEBABY] = "Tainted ???",
    [PlayerType.PLAYER_EVE] = "Tainted Eve",
    [PlayerType.PLAYER_SAMSON] = "Tainted Samson",
    [PlayerType.PLAYER_AZAZEL] = "Tainted Azazel",
    [PlayerType.PLAYER_LAZARUS] = "Tainted Lazarus",
    [PlayerType.PLAYER_EDEN] = "Tainted Eden",
    [PlayerType.PLAYER_THELOST] = "Tainted Lost",
    [PlayerType.PLAYER_LAZARUS2] = "Tainted Lazarus",
    [PlayerType.PLAYER_BLACKJUDAS] = "Tainted Judas",
    [PlayerType.PLAYER_LILITH] = "Tainted Lilith",
    [PlayerType.PLAYER_KEEPER] = "Tainted Keeper",
    [PlayerType.PLAYER_APOLLYON] = "Tainted Apollyon",
    [PlayerType.PLAYER_THEFORGOTTEN] = "Tainted Forgotten",
    [PlayerType.PLAYER_THESOUL] = "Tainted Forgotten",
    [PlayerType.PLAYER_BETHANY] = "Tainted Bethany",
    [PlayerType.PLAYER_JACOB] = "Tainted Jacob",
    [PlayerType.PLAYER_ESAU] = "Tainted Jacob",
}

--- Returns the name of the currently played character.
--- @return string
function export.getCharacterName()
    return export.playerTypeNames[Isaac.GetPlayer():GetPlayerType()]
end

--- 'true' if the currently played character is tainted.
--- @return boolean
function export.isCharacterTainted()
    return export.taintedCharacters[Isaac.GetPlayer():GetPlayerType()] ~= nil
end

--- Returns the name of the current character's tainted counterpart.
--- 'nil' if the current character is tainted.
--- @return string|nil
function export.getTaintedCharacterName()
    return export.taintedCounterpartNames[Isaac.GetPlayer():GetPlayerType()]
end

--- Picks a random value from the table.
--- @param rng RNG
--- @param table table
--- @return any
function export.randomFromTable(rng, table)
    local keys = export.tableKeys(table)
    return table[rng:RandomInt(#keys) + 1]
end

--- Picks a random value from the array.
--- @param rng RNG
--- @param table any[]
--- @return any
function export.randomFromArray(rng, table)
    return table[rng:RandomInt(#table) + 1]
end

--- Shuffles an array in-place.
--- @param rng RNG
--- @param table any[]
function export.shuffleTable(rng, table)
    for i = #table, 2, -1 do
        local j = rng:RandomInt(i) + 1
        table[i], table[j] = table[j], table[i]
    end
end

--- Concatenates all given arrays into a single output array.
--- @param arrays table[]
--- @return table
function export.concatArrays(arrays)
    local collection = {}
    for _, array in ipairs(arrays) do
        for _, value in ipairs(array) do
            collection[#collection + 1] = value
        end
    end

    return collection
end

--- Merges the given tables together into a single table.
--- @param tables table[]
--- @return table
function export.mergeTables(tables)
    local outTable = {}

    for _, tab in ipairs(tables) do
        for k, v in pairs(tab) do
            outTable[k] = v
        end
    end

    return outTable
end

--- Returns all of the keys for the table as an array.
--- @param table table
--- @return integer[]|string[]
function export.tableKeys(table)
    local keys = {}

    for key, _ in pairs(table) do
        keys[#keys + 1] = key
    end

    return keys
end

-- http://lua-users.org/wiki/StringRecipes

--- Returns 'true' if the string starts with the given substring.
--- @param str string
--- @param startsWith string
--- @return boolean
function export.stringStartsWith(str, startsWith)
	return str:sub(1, #startsWith) == startsWith
end

--- Returns 'true' if the string ends with the given substring.
--- @param str string
--- @param endsWith string
--- @return boolean
function export.stringEndsWith(str, endsWith)
	return endsWith == "" or str:sub(-#endsWith) == endsWith
end

--- Splits a string into an array of substrings by a delimitter.
--- @param str string
--- @param delimiter string
--- @return string[]
function export.stringSplit(str, delimiter)
	local output = {}
	local i = 1
	
	for match in string.gmatch(str, '([^'..delimiter..']+)') do
		output[i] = match
		i = i + 1
	end
	
	return output
end

--- Turns a table into a string.
--- @param table table
--- @return string
function export.tableToString(table)
    local str = ""
    for key, value in pairs(table) do
        str = str .. key .. ": " .. value .. ", "
    end

    return "{" .. string.sub(str, 1, #str - 2) .. "}"
end

--- Turns an array into a string.
--- @param array table
--- @return string
function export.arrayToString(array)
    local str = ""
    for key, value in ipairs(array) do
        str = str .. key .. ": " .. value .. ", "
    end

    return "[" .. string.sub(str, 1, #str - 2) .. "]"
end

--- Splits an array into smaller arrays.
--- @param tab table
--- @param count number The number of entries in each arrray.
--- @return table
function export.chunkArray(tab, count)
    local out = {}

    for i = 1, #tab, count do
        out[#out + 1] = {table.unpack(tab, i, math.min(#tab, i + count - 1))}
    end

    return out
end

--- Returns the value clamped between min and max, inclusive.
--- @param value number
--- @param min number
--- @param max number
--- @return number
function export.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

--- Returns the input table, but the keys and values are swapped.
--- @param tab table
--- @return table
function export.invertTable(tab)
    local newTable = {}
    for key, value in pairs(tab) do
        newTable[value] = key
    end

    return newTable
end

--- Creates a shallow copy of the table.
--- @param tab table
--- @return table
function export.shallowCopyTable(tab)
    local out = {}
    for k, v in pairs(tab) do
        out[k] = v
    end

    return out
end

--- Linearly interpolates a value.
--- @param from number
--- @param to number
--- @param amount number
--- @return number
function export.lerp(from, to, amount)
    return (1 - amount) * from + amount * to
end

--- Creates an RNG object, by seeding it with the run's seed.
--- @return RNG
function export.getRNG()
    local startSeed = Game():GetSeeds():GetStartSeed()
    local rng = RNG()
    rng:SetSeed(startSeed, 35) -- 35 is the 'recommended shift index,' whatever that means

    return rng
end

--- 'True' if the room is the final boss room of the floor.
--- This is helpful in case Curse of the Labyrinth is on.
--- @param room Room
--- @return boolean
function export.isChapterEndBoss(room)
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

--- Returns which stage this is.
--- For labyrinth stages, this will be the latter half of the chapter (1_1 -> 1_2)
--- @param level Level
--- @return LevelStage
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

--- Removes the alt path door in boss rooms, the ascent door in Depths, the blue womb door in Womb II, and the Void door in Blue Womb.
--- @param room Room
function export.removeSecretExit(room)
    for slot, door in export.doors(room) do
        if door then
            if door.TargetRoomType == RoomType.ROOM_SECRET_EXIT then -- Secret exit doors
                room:RemoveDoor(slot)
            elseif export.isBlueWombDoor(door) then -- Blue Womb door in Womb II
                room:RemoveDoor(slot)
            end
        end
    end

    -- Void door in Blue Womb
    if room:GetType() == RoomType.ROOM_BOSS and Game():GetLevel():GetStage() == LevelStage.STAGE4_3 then
        room:RemoveDoor(DoorSlot.UP1)
    end
end

local itemConfig = Isaac.GetItemConfig()

--- Adds a collectible's costum to the player.
--- @param player EntityPlayer
--- @param collectibleType CollectibleType
--- @param addToTwin boolean
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

--- True if the player owns the given trinket (gulped or otherwise).
--- @param player EntityPlayer
--- @param trinketType TrinketType
--- @return boolean
function export.hasTrinket(player, trinketType)
    return player:GetTrinketMultiplier(trinketType) > 0
end

--- True if the player has all of the given collectibles
--- @param player EntityPlayer
--- @param collectibleTypes CollectibleType[]
--- @return boolean
function export.hasAllCollectibles(player, collectibleTypes)
    for _, collectibleType in ipairs(collectibleTypes) do
        if not player:HasCollectible(collectibleType, true) then
            return false -- Player doesn't have one of the collectibles :(
        end
    end

    return true
end

--- Returns the total number of collectibles matching the given collectibles.
--- @param player EntityPlayer
--- @param collectibleTypes CollectibleType[]
--- @return integer
function export.countCollectibleTypes(player, collectibleTypes)
    local count = 0

    for _, collectibleType in ipairs(collectibleTypes) do
        count = count + player:GetCollectibleNum(collectibleType, true)
    end

    return count
end

-- These familiars don't really count as familiars
local disallowedFamiliars = {
    [FamiliarVariant.BLUE_FLY] = true,
    [FamiliarVariant.BLUE_SPIDER] = true,
    [FamiliarVariant.DIP] = true,
    [FamiliarVariant.ABYSS_LOCUST] = true,
    [FamiliarVariant.MINISAAC] = true,
    [FamiliarVariant.BROWN_NUGGET_POOTER] = true,
    [FamiliarVariant.ITEM_WISP] = true,
    [FamiliarVariant.KNIFE_PIECE_1] = true,
    [FamiliarVariant.KNIFE_PIECE_2] = true, -- I'd argue the full knife is a true familiar
    [FamiliarVariant.KEY_PIECE_1] = true,
    [FamiliarVariant.KEY_PIECE_2] = true,
    [FamiliarVariant.KEY_FULL] = true,
    [FamiliarVariant.FORGOTTEN_BODY] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.SWARM_FLY_ORBITAL] = true,
    [FamiliarVariant.SIREN_MINION] = true,
    [FamiliarVariant.TINYTOMA_2] = true,
    [FamiliarVariant.BONE_ORBITAL] = true,
    [FamiliarVariant.FLY_ORBITAL] = true
}

--- Returns number of familiars, and if Super Meat Boy/Bandage Girl exists.
--- @return {count: integer, meat_boy: boolean, bandage_girl: boolean, charmed_count: integer}
function export.familiarStatus()
    local count = 0
    local meatBoy = false
    local bandageGirl = false
    local charmedCount = 0

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local familiar = entity:ToFamiliar()

        if familiar ~= nil then
            if not disallowedFamiliars[entity.Variant] then
                count = count + 1
            end

            -- Super Meat Boy!
            if familiar.Variant == FamiliarVariant.CUBE_OF_MEAT_4 then
                meatBoy = true

            -- Super Bandage Girl!
            elseif familiar.Variant == FamiliarVariant.BALL_OF_BANDAGES_4 then
                bandageGirl = true
            end
        elseif entity:GetEntityFlags() & EntityFlag.FLAG_CHARM ~= 0 then
            charmedCount = charmedCount + 1
        end
    end

    return {
        count = count,
        meat_boy = meatBoy,
        bandage_girl = bandageGirl,
        charmed_count = charmedCount
    }
end

--- Iterates through each door a room can have. If the door doesn't exist, the second value will be nil.
--- @param room Room
--- @return fun(): DoorSlot|nil, GridEntityDoor|nil
function export.doors(room)
    --- @type DoorSlot
    local slot = DoorSlot.LEFT0 - 1

    return function()
        slot = slot + 1
        if slot < DoorSlot.NUM_DOOR_SLOTS then
            return slot, room:GetDoor(slot)
        end
    end
end

--- Iterates through each grid entity in a room. If the grid entity doesn't exist, the second value will be null.
--- @param room Room
--- @return fun(): integer|nil, GridEntity|nil
function export.gridEntities(room)
    local gridIndex = -1
    local maxGridIndex = room:GetGridSize()

    return function()
        gridIndex = gridIndex + 1
        if gridIndex < maxGridIndex then
            return gridIndex, room:GetGridEntity(gridIndex)
        end
    end
end

--- Returns the amount of health the player has, where 1 = one half-heart.
--- @param player EntityPlayer
--- @return integer
function export.totalPlayerHealth(player)
    return player:GetHearts() + player:GetSoulHearts() + player:GetEternalHearts() + player:GetBoneHearts()
end

--- Returns an option from the table, but options are weighted.
--- @generic T
--- @param options {value: T, weight: number}[]
--- @param rng? RNG If omitted, the 'math' module will be used instead.
--- @return T
function export.chooseWeighted(options, rng)
    -- Calculate total weight
    local totalWeight = 0

    for _, option in ipairs(options) do
        totalWeight = totalWeight + option.weight
    end

    -- Go through each item and subtract until we hit 0 on our counter
    local counter

    if rng ~= nil then
        counter = rng:RandomFloat() * totalWeight -- RNG is supplied
    else
        counter = math.random() * totalWeight -- RNG is not supplied
    end

    for _, option in ipairs(options) do
        counter = counter - option.weight

        if counter <= 0 then
            return option.value
        end
    end

    -- Fallback value
    return options[1].value
end

--- 'true' when the given GridEntityDoor is the door to the Blue Womb room on Womb II. (Say that five times fast)
--- @param door GridEntityDoor
--- @return boolean
function export.isBlueWombDoor(door)
    return door:GetSprite():GetFilename() == "gfx/grid/door_29_doortobluewomb.anm2"
end

--- Creates a unit vector pointed in a random direction.
--- @param rng RNG
function export.randomVector(rng)
    local angle = rng:RandomFloat() * math.pi * 2
    return Vector(math.cos(angle), math.sin(angle))
end

--- Gets an array of entities created this frame (FrameCount <= 0).
--- @param type EntityType
--- @param variant? integer @default: '-1'
--- @param subType? integer @default: '-1'
--- @return Entity[]
function export.getNewEntitiesThisFrame(type, variant, subType)
    if variant == nil then
        variant = -1
    end

    if subType == nil then
        subType = -1
    end

    local entities = {}
    for _, entity in ipairs(Isaac.FindByType(type, variant, subType)) do
        if entity.FrameCount <= 0 then
            entities[#entities + 1] = entity
        end
    end

    return entities
end

--- Gets the tearflag bitset for the given tearflag number.
--- @param x integer
--- @return BitSet128
function export.tearflag(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end

return export