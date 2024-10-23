--[[
    Sonaran CAD Plugins

    Plugin Name: locations
    Creator: SonoranCAD
    Description: Implements location updating for players
]]
CreateThread(function() Config.LoadPlugin("locations", function(pluginConfig)

if pluginConfig.enabled then

    local currentLocation = ''
    local lastLocation = 'none'
    local lastSentTime = nil
    local lastCoords = { x = 0, y = 0, z = 0 }

    local function sendLocation()
        local pos = GetEntityCoords(PlayerPedId())
        local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        local postal = nil
        if isPluginLoaded("postals") then
            postal = getNearestPostal()
        else
            pluginConfig.prefixPostal = false
        end
        local l1 = GetStreetNameFromHashKey(var1)
        local l2 = GetStreetNameFromHashKey(var2)
        if l2 ~= '' then
            currentLocation = l1 .. ' / ' .. l2
        else
            currentLocation = l1
        end
        if (currentLocation ~= lastLocation or vector3(pos.x, pos.y, pos.z) ~= vector3(lastCoords.x, lastCoords.y, lastCoords.z))  then
            -- Location changed, continue
            local toSend = currentLocation
            if pluginConfig.prefixPostal and postal ~= nil then
                toSend = "["..tostring(postal).."] "..currentLocation
            elseif postal == nil and pluginConfig.prefixPostal == true then
                debugLog("Unable to send postal because I got a null response from getNearestPostal()?!")
            end
            TriggerServerEvent('SonoranCAD::locations:SendLocation', toSend, pos) 
            lastCoords = pos
            debugLog(("Locations different, sending. (%s ~= %s) SENT: %s (POS: %s)"):format(currentLocation, lastLocation, toSend, json.encode(lastCoords)))
            lastSentTime = GetGameTimer()
            lastLocation = currentLocation
        end
    end

    Citizen.CreateThread(function()
        -- Wait for plugins to settle
        Wait(5000)
        while true do
            while not NetworkIsPlayerActive(PlayerId()) do
                Wait(10)
            end
            sendLocation()
            -- Wait (1000ms) before checking for an updated unit location
            Citizen.Wait(pluginConfig.checkTime)
        end
    end)

    Citizen.CreateThread(function()
        while lastSentTime == nil do
            while not NetworkIsPlayerActive(PlayerId()) do
                Wait(10)
            end
            Wait(15000)
            if lastSentTime == nil then
                TriggerServerEvent("SonoranCAD::locations:ErrorDetection", true)
                warnLog("Warning: No location data has been sent yet. Check for errors.")
            end
            Wait(30000)
        end
    end)

end

end) end)