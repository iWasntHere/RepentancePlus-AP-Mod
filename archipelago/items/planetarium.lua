local util = Archipelago.util

--- Handles the planetarium being locked.
Archipelago:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    if Archipelago:checkUnlockedByName("The Planetarium") then
        return -- It's unlocked so do nothing
    end

    -- If the planetarium is adjacent, remove the door to it
    local room = Archipelago.room()
    for slot, door in util.doors(room) do
        if door and door.TargetRoomType == RoomType.ROOM_PLANETARIUM then
            room:RemoveDoor(slot)
        end
    end

    -- We entered the planetarium, so kick the player out
    if room:GetType() == RoomType.ROOM_PLANETARIUM then
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, UseFlag.USE_NOANIM)
    end
end)