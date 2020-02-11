---------------------------------------------------------------------------
-- Reading Config options from config.json
---------------------------------------------------------------------------
--[[ local loadFile = LoadResourceFile(GetCurrentResourceName(), "./config.json")
local config = {}
config = json.decode(loadFile) ]]

local checkTime = 1000 -- Location check time in milliseconds

---------------------------------------------------------------------------
-- Client Event Handling **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
RegisterNetEvent('cadSendPanic')
AddEventHandler('cadSendPanic', function()
    TriggerServerEvent('cadSendPanicApi', identifier)
end)

        ---------------------------------
        -- Unit Location Update
        ---------------------------------
Citizen.CreateThread(function()
    -- print(checkTime)
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        -- Determine location format
        if (GetStreetNameFromHashKey(var2) == '') then
            currentLocation = GetStreetNameFromHashKey(var1)
            if (identifier ~= nil) then
                if (currentLocation ~= lastLocation) then
                    -- Updated location - Save and send to server API call queue
                    lastLocation = currentLocation
                    TriggerServerEvent('cadSendLocation', identifier, currentLocation) 
                end
            end
        else 
            currentLocation = GetStreetNameFromHashKey(var1) .. ' / ' .. GetStreetNameFromHashKey(var2)
            if (identifier ~= nil) then
                if (currentLocation ~= lastLocation) then
                    -- Updated location - Save and send to server API call queue
                    lastLocation = currentLocation
                    TriggerServerEvent('cadSendLocation', identifier, currentLocation) 
                end
            end
        end
        -- Wait (1000ms) before checking for an updated unit location
        Citizen.Wait(checkTime)
    end
end)

        ---------------------------------
        -- Steam Hex Request
        ---------------------------------
Citizen.CreateThread(function()
    while (identifier == nil) do --Teminate Thread after recieving SteamHex from Server
        if (identifier == nil) then
            -- Identifier is not yet set -> Request Steam Hex from server
            TriggerServerEvent('GetSteamHex', GetPlayerServerId(PlayerId()))
        end
        Citizen.Wait(1000)
    end
end)

-- Reciever Event to get steamHex from server
RegisterNetEvent('ReturnSteamHex')
AddEventHandler('ReturnSteamHex', function(steamHex)
    identifier = steamHex
end)