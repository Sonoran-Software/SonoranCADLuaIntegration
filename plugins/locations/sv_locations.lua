--[[
    Sonaran CAD Plugins

    Plugin Name: locations
    Creator: SonoranCAD
    Description: Implements location updating for players
]]
local pluginConfig = Config.plugins["locations"]

-- Pending location updates array
LocationCache = {}

-- Main api POST function
local function SendLocations()
    for k, v in pairs(LocationCache) do
        LocationCache[k].playerId = nil
    end
    performApiRequest(LocationCache, 'UNIT_LOCATION', function() end)
end

function findPlayerLocation(playerSrc)
    for k, v in pairs(LocationCache) do
        if v.playerId == playerSrc then
            return v.location
        end
    end
    return nil
end

-- Main update thread sending api location update POST requests per the postTime interval
Citizen.CreateThread(function()
    Wait(0)
    while true do
        if #LocationCache > 0 then
            -- Make API request if 1 or more updates exist
            SendLocations()
        end
        -- Wait the (5000ms) delay to check for pending location calls
        Citizen.Wait(pluginConfig.checkTime)
    end
end)

-- Event from client when location changes occur
RegisterServerEvent('cadSendLocation')
AddEventHandler('cadSendLocation', function(currentLocation)
    -- Does this client location already exist in the pending location array?
    local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
    if Config.serverType == "esx" then
        identifier = ("%s:%s"):format(Config.primaryIdentifier, identifier)
    end
    local index = findIndex(identifier)
    if index then
        -- Location already in pending array -> Update
        LocationCache[index].location = currentLocation
    else
        -- Location does not exist in pending array -> Insert new location object
        table.insert(LocationCache, {['playerId'] = source, ['apiId'] = identifier, ['location'] = currentLocation})
    end
end)

AddEventHandler("playerDropped", function()
    for k, v in pairs(LocationCache) do
        if v.playerId == source then
            LocationCache[k] = nil
            return
        end
    end
end)