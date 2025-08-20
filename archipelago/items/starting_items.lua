local nextFrameFunctions = {} -- Functions to run on the next frame

--- Removes instrinsic effects from characters.
--- @param player EntityPlayer
--- @param playerType PlayerType
local function removeInstrinsicItemEffects(player, playerType)
    -- Remove Lost's Holy Mantle
    if playerType == PlayerType.PLAYER_THELOST and not Archipelago:checkUnlockedByName("Lost Holds Holy Mantle") then
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true) then
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, 1)
        end

    -- Remove Anemic from Lazarus TODO: This doesn't actually work
    elseif playerType == PlayerType.PLAYER_LAZARUS and not Archipelago:checkUnlockedByName("Lazarus Bleeds More!") then
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC, true) then
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_ANEMIC, 1)
        end
    end
end

--- Removes locked items that characters may start with.
--- @param continued boolean
Archipelago:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    local player = Isaac.GetPlayer(0)
    local playerType = player:GetPlayerType()

    removeInstrinsicItemEffects(player, playerType)

    if continued then
        return
    end

    -- Remove D6 from Isaac's starting items
    if playerType == PlayerType.PLAYER_ISAAC and not Archipelago:checkUnlockedByName("The D6") then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_D6)
    
    -- Remove the pill from Magdalene
    elseif playerType == PlayerType.PLAYER_MAGDALENE and not Archipelago:checkUnlockedByName("Maggy Now Holds a Pill!") then
        -- First we drop the pill, then on the next frame, delete it
        player:DropPocketItem(0, Vector(0, 0))
        nextFrameFunctions[#nextFrameFunctions + 1] = function ()
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_PILL then
                    entity:Remove()
                end
            end
        end

    -- Remove Paperclip from Cain
    elseif playerType == PlayerType.PLAYER_CAIN and not Archipelago:checkUnlockedByName("Cain Holds Paper Clip") then
        player:TryRemoveTrinket(TrinketType.TRINKET_PAPER_CLIP)

    -- Remove Child's Heart from Samson
    elseif playerType == PlayerType.PLAYER_SAMSON and not Archipelago:checkUnlockedByName("Samson Feels Healthy!") then
        player:TryRemoveTrinket(TrinketType.TRINKET_CHILDS_HEART)

    -- Remove Eve's Razor Blade
    elseif playerType == PlayerType.PLAYER_EVE and not Archipelago:checkUnlockedByName("Eve Now Holds Razor Blade") then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_RAZOR_BLADE)

    -- Remove Keeper's stuff
    elseif playerType == PlayerType.PLAYER_KEEPER then
        -- Wooden Nickel
        if not Archipelago:checkUnlockedByName("Keeper Holds Wooden Nickel") then
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_WOODEN_NICKEL)
        end

        -- Store Key
        if not Archipelago:checkUnlockedByName("Keeper Holds Store Key") then
            player:TryRemoveTrinket(TrinketType.TRINKET_STORE_KEY)
        end

        -- Extra heart
        if not Archipelago:checkUnlockedByName("Keeper Holds a Penny") then
            player:AddMaxHearts(-2)
        end
    end
end)

--- Remove character's instrinsic item effects if they are locked (such as Lost's Holy mantle).
--- Those items are granted back to the character every room load.
Archipelago:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    local player = Isaac.GetPlayer(0)
    local playerType = player:GetPlayerType()

    nextFrameFunctions[#nextFrameFunctions + 1] = function ()
        removeInstrinsicItemEffects(player, playerType)
    end
end)

--- Runs functions a frame later if needed.
Archipelago:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    for _, func in ipairs(nextFrameFunctions) do
        func()
    end

    nextFrameFunctions = {}
end)