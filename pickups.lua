-- Provides callbacks for picking up pickups and opening chests

AP_MAIN_MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, pickup)
    local data = pickup:GetData()

    -- Ensure that we have not already ran the callback for picking this up
    if data.archipelago_picked_up then

        -- Eternal Chests can re-close when opened
        if pickup.Variant == PickupVariant.PICKUP_ETERNALCHEST then
            local sprite = pickup:GetSprite()
            if sprite:IsPlaying("Idle") then
                data.archipelago_picked_up = false -- Unset that we've processed, so we can do it again
            else
                return
            end
        else
            return
        end
    end

    local sprite = pickup:GetSprite()

    if sprite:IsPlaying("Collect") then -- This is a regular pickup (heart, coin, bomb, etc)
        data.archipelago_picked_up = true

        Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_PICKUP_PICKED, pickup)
    elseif sprite:IsPlaying("Open") then -- This is a chest
        data.archipelago_picked_up = true

        Isaac.RunCallback(ArchipelagoModCallbacks.MC_ARCHIPELAGO_CHEST_OPENED, pickup)
    end
end)