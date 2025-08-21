local export = {}

--- @type {primary_text: string, secondary_text: string, sound?: SoundEffect, displayFunc?: function}[]
local queue = {}
local isPlaying = false
local playingTime = 0
local hud = Archipelago.hud

--- Enqueues a notification to the system.
--- @param primaryText string
--- @param secondaryText string
--- @param sound? SoundEffect
--- @param displayFunc? function The function to run when the notification is displayed
function export.enqueueNotification(primaryText, secondaryText, sound, displayFunc)
    queue[#queue + 1] = {
        primary_text = primaryText,
        secondary_text = secondaryText,
        sound = sound,
        displayFunc = displayFunc
    }
end

--- Creates and enqueues a notification for receiving or sending an item.
--- @param itemName string The item's name
--- @param playerName string The player that sent the item
--- @param locationName string The location the item came from
--- @param isTrap boolean If the item is considered a trap (a bad item)
--- @param isReceived boolean Whether the item is being sent, or received
--- @param displayFunc? function The function to run when the notification is displayed
function export.createItemNotification(itemName, playerName, locationName, isTrap, isReceived, displayFunc)
    local primaryText = itemName
    local secondaryText

    if isReceived then
        if playerName ~= ArchipelagoSlot.SLOT_NAME then -- Someone else sent us this item
            secondaryText = "from " .. playerName .. " has appeared in the basement"
        else -- We got ourselves this item
            secondaryText = "has appeared in the basement"
        end
    else -- We got someone else's item
        secondaryText = "for " .. playerName .. " has left the basement"
    end

    local sound = nil
    if isTrap then
        sound = SoundEffect.SOUND_THUMBS_DOWN
    else
        sound = SoundEffect.SOUND_THUMBSUP
    end

    export.enqueueNotification(primaryText, secondaryText, sound, displayFunc)
end

--- Handles playing the animations for each notification.
Archipelago:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if isPlaying then -- Already playing an animation
        playingTime = playingTime + 1

        if playingTime > 2.5 * 30 then -- Animation should be finished by now, allow another to play
            playingTime = 0
            isPlaying = false
        end

        return
    end

    if #queue == 0 then -- Nothing in queue
        return
    end

    -- Dequeue
    local notification = table.remove(queue, 1)
    hud:ShowItemText(notification.primary_text, notification.secondary_text)

    -- Play a sound if one was given
    if notification.sound then
        Archipelago.sfxManager:Play(notification.sound)
    end

    -- Run a function if one was given
    if notification.displayFunc then
        notification.displayFunc()
    end

    isPlaying = true
end)

return export