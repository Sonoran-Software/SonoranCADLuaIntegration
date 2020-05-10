--[[
    Sonaran CAD Plugins

    Plugin Name: postals
    Creator: SonoranCAD
    Description: Fetches nearest postal from client
]]

-- Toggles Postal Sender
RegisterNetEvent("getShouldSendPostal")
AddEventHandler("getShouldSendPostal", function()
    TriggerClientEvent("getShouldSendPostalResponse", source, prefixPostal)
end)