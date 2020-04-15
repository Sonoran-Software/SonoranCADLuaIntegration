--[[
    Nearest Postal Integration

    This resource sends postal data to the server on request.

    DOES NOTHING BY DEFAULT. Add client-side code here to get the player's postal code.
]]

shouldSendPostalData = false
local postalPulseTimer = 950 -- how often to send postal data? Set slightly more often than location sends to prevent race conditions.

-- edit this function with your code
function getPostal()
    return nil -- remove this line!

end


-- Don't touch this!
local function sendPostalData()
    local postal = getPostal()
    if postal ~= nil then
        TriggerServerEvent("cadClientPostal", postal)
    end
end
CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(10)
    end
    TriggerServerEvent("getShouldSendPostal")
    while true do
        if shouldSendPostalData then
            sendPostalData()
        end
        Wait(postalPulseTimer)
    end
end)

RegisterNetEvent("getShouldSendPostalResponse")
AddEventHandler("getShouldSendPostalResponse", function(toggle)
    shouldSendPostalData = toggle
end)