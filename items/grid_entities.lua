local util = require("util")

local gridEntityTypeToName = {
    [GridEntityType.GRID_ROCK_SS] = "Super Special Rocks",
    [GridEntityType.GRID_ROCK_GOLD] = "Fool's Gold",
    [GridEntityType.GRID_ROCK_ALT2] = "A Mysterious Door"
}

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    local room = Game():GetLevel():GetCurrentRoom()
    local toSpawn = {} -- Table of index to type to spawn

    local gridEntityTypeToUnlocked = {}

    -- Loop through all grid entities, test if they need to be removed
    for i = 0, room:GetGridSize(), 1 do
        local gridEnt = room:GetGridEntity(i)
        if gridEnt then
            local type = gridEnt:GetType()
            local name = gridEntityTypeToName[type]

            if name then
                local isUnlocked = gridEntityTypeToUnlocked[type]
                if isUnlocked == nil then -- We can cache the value to make this faster (on this loop)
                    isUnlocked = AP_MAIN_MOD:checkUnlockedByName(name)
                    gridEntityTypeToUnlocked[type] = isUnlocked
                end

                if not AP_MAIN_MOD:checkUnlockedByName(name) then
                    room:RemoveGridEntity(i, 0, true)
                    gridEnt:Update()
                    toSpawn[i] = GridEntityType.GRID_ROCK
                end
            end
        end
    end

    -- Do we need to spawn anything?
    if #util.table_keys(toSpawn) == 0 then
        return
    end

    room:Update() -- We have to update the room after we remove a grid entity because we're in hell.

    local rng = util.getRNG()
    for index, type in pairs(toSpawn) do
        rng:Next()
        room:SpawnGridEntity(index, type, 0, rng:GetSeed(), 0)
    end

    -- room:Update() -- Unsure if we really need this as of now
end)