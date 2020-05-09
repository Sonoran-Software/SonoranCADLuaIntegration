-- Toggles Postal Sender
RegisterNetEvent("getShouldSendPostal")
AddEventHandler("getShouldSendPostal", function()
    TriggerClientEvent("getShouldSendPostalResponse", source, prefixPostal)
end)