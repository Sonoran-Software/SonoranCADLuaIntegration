--[[
    Sonaran CAD Plugins

    Plugin Name: locations
    Creator: SonoranCAD
    Description: Implements location updating for players
]]
local pluginConfig = Config.plugins["locations"]

local currentLocation = nil

Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        local postal = nil
        if isPluginLoaded("postals") then
            postal = getNearestPostal()
        else
            pluginConfig.prefixPostal = false
        end
        -- Determine location format
        if (GetStreetNameFromHashKey(var2) == '') then
            currentLocation = GetStreetNameFromHashKey(var1)
            if (currentLocation ~= lastLocation) then
                -- Updated location - Save and send to server API call queue
                lastLocation = currentLocation
            end
        else 
            currentLocation = GetStreetNameFromHashKey(var1) .. ' / ' .. GetStreetNameFromHashKey(var2)
            if (currentLocation ~= lastLocation) then
                -- Updated location - Save and send to server API call queue
                lastLocation = currentLocation
            end
        end
        if pluginConfig.prefixPostal and postal ~= nil then
            currentLocation = "["..tostring(postal).."] "..currentLocation
        end
        TriggerServerEvent('SonoranCAD::locations:SendLocation', currentLocation) 
        -- Wait (1000ms) before checking for an updated unit location
        Citizen.Wait(pluginConfig.checkTime)
    end
end)