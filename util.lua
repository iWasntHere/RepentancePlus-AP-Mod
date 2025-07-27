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
    [PlayerType.PLAYER_THESOUL_B] = "Tainted Forgotten",
}

function export.get_character_name ()
    return export.playerTypeNames[Isaac.GetPlayer():GetPlayerType()]
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

return export