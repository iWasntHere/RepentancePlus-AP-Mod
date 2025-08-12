local nextFrameFunctions = {} -- Functions to run on the next frame

--- Removes instrinsic effects from characters.
--- @param player EntityPlayer
--- @param playerType PlayerType
local function removeInstrinsicItemEffects(player, playerType)
    -- Remove Lost's Holy Mantle
    if playerType == PlayerType.PLAYER_THELOST and not AP_MAIN_MOD:checkUnlockedByName("Lost Holds Holy Mantle") then
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true) then
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, 1)
        end

    -- Remove Anemic from Lazarus TODO: This doesn't actually work
    elseif playerType == PlayerType.PLAYER_LAZARUS and not AP_MAIN_MOD:checkUnlockedByName("Lazarus Bleeds More!") then
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC, true) then
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_ANEMIC, 1)
        end
    end
end

--- Removes locked items that characters may start with.
--- @param continued boolean
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
    local player = Isaac.GetPlayer(0)
    local playerType = player:GetPlayerType()

    removeInstrinsicItemEffects(player, playerType)

    if continued then
        return
    end

    -- Remove D6 from Isaac's starting items
    if playerType == PlayerType.PLAYER_ISAAC and not AP_MAIN_MOD:checkUnlockedByName("The D6") then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_D6)
    
    -- Remove the pill from Magdalene
    elseif playerType == PlayerType.PLAYER_MAGDALENE and not AP_MAIN_MOD:checkUnlockedByName("Maggy Now Holds a Pill") then
        -- First we drop the pill, then on the next frame, delete it
        player:DropPocketItem(0, Vector(0, 0))
        nextFrameFunctions[#nextFrameFunctions + 1] = function ()
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_PILL then
                    entity:Remove()
                end
            end
        end

    -- Remove Child's Heart from Samson
    elseif playerType == PlayerType.PLAYER_SAMSON and not AP_MAIN_MOD:checkUnlockedByName("Samson Feels Healthy!") then
        player:TryRemoveTrinket(TrinketType.TRINKET_CHILDS_HEART)

    -- Remove Keeper's stuff
    elseif playerType == PlayerType.PLAYER_KEEPER then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_WOODEN_NICKEL)
        player:TryRemoveTrinket(TrinketType.TRINKET_STORE_KEY)
    end
end)

--- Remove character's instrinsic item effects if they are locked (such as Lost's Holy mantle).
--- Those items are granted back to the character every room load.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    local player = Isaac.GetPlayer(0)
    local playerType = player:GetPlayerType()

    nextFrameFunctions[#nextFrameFunctions + 1] = function ()
        removeInstrinsicItemEffects(player, playerType)
    end
end)

--- Runs functions a frame later if needed.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    for _, func in ipairs(nextFrameFunctions) do
        func()
    end

    nextFrameFunctions = {}
end)