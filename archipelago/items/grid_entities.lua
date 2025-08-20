local util = Archipelago.util

local gridEntityTypeToName = {
    [GridEntityType.GRID_ROCK_SS] = "Super Special Rocks",
    [GridEntityType.GRID_ROCK_GOLD] = "Fool's Gold",
    [GridEntityType.GRID_ROCK_ALT2] = "A Strange Door",
}

Archipelago:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    local room = Game():GetLevel():GetCurrentRoom()
    local toSpawn = {} -- Table of index to type to spawn

    local gridEntityTypeToUnlocked = {}

    -- Loop through all grid entities, test if they need to be removed
    for i = 0, room:GetGridSize(), 1 do
        local gridEnt = room:GetGridEntity(i)
        if gridEnt then
            local type = gridEnt:GetType()
            local variant = gridEnt:GetVariant()
            
            local shouldRemove = false

            -- Super Secret Rocks
            if type == GridEntityType.GRID_ROCK_SS then
                if not Archipelago:checkUnlockedByName("Super Special Rocks") then
                    shouldRemove = true

                    toSpawn[i] = GridEntityType.GRID_ROCK
                end

            -- Fool's Gold
            elseif type == GridEntityType.GRID_ROCK_GOLD then
                if not Archipelago:checkUnlockedByName("Fool's Gold") then
                    shouldRemove = true

                    toSpawn[i] = GridEntityType.GRID_ROCK
                end

            -- Tinted Skull
            elseif type == GridEntityType.GRID_ROCK_ALT2 then
                if not Archipelago:checkUnlockedByName("A Strange Door") then
                    shouldRemove = true
                end

            -- Charming Poop
            elseif type == GridEntityType.GRID_POOP and variant == 11 then -- '11' being Charming Poop in this instance
                if not Archipelago:checkUnlockedByName("Charming Poop") then
                    shouldRemove = true

                    toSpawn[i] = GridEntityType.GRID_POOP
                end
            end

            -- Remove if needed
            if shouldRemove then
                room:RemoveGridEntity(i, 0, true)
                gridEnt:Update()
            end
        end
    end

    -- Do we need to spawn anything?
    if #util.tableKeys(toSpawn) == 0 then
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