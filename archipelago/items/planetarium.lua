local util = require("archipelago.util")

--- Handles the planetarium being locked.
AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    if AP_MAIN_MOD:checkUnlockedByName("The Planetarium") then
        return -- It's unlocked so do nothing
    end

    -- If the planetarium is adjacent, remove the door to it
    local room = Game():GetRoom()
    for slot, door in util.doors(room) do
        if door and door.TargetRoomType == RoomType.ROOM_PLANETARIUM then
            room:RemoveDoor(slot)
        end
    end

    -- We entered the planetarium, so kick the player out
    if room:GetType() == RoomType.ROOM_PLANETARIUM then
        Isaac.GetPlayer(0):UseCard(Card.CARD_STARS, UseFlag.USE_NOHUD)
    end
end)