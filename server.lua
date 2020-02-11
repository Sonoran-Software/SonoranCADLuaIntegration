---------------------------------------------------------------------------
-- Config Options **EDIT THESE**
---------------------------------------------------------------------------
local communityID = ""
local apiKey = ""
local apiURL = 'https://sonorancad.com/api/emergency'
local postTime = 5000 --Recommended to stay above 5000ms

---------------------------------------------------------------------------
-- Server Event Handling **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------

-- Return client SteamHex request
RegisterServerEvent("GetSteamHex")
AddEventHandler("GetSteamHex", function(srscsd)
    local steamHex = GetPlayerIdentifier(srscsd, 0)
    TriggerClientEvent('ReturnSteamHex', srscsd, steamHex)
end)

        ---------------------------------
        -- Unit Panic
        ---------------------------------
 
-- Client Panic request
RegisterServerEvent('cadSendPanicApi')
AddEventHandler('cadSendPanicApi', function(steamHex, currentLocation)
    PerformHttpRequest(apiURL, function(statusCode, res, headers) 
    end, "POST", json.encode({['id'] = communityID, ['key'] = apiKey, ['type'] = 'UNIT_PANIC', ['data'] = {{ ['isPanic'] = true, ['apiId'] = steamHex}}}), {["Content-Type"]="application/json"})
end)

        ---------------------------------
        -- Unit Location Update
        ---------------------------------

-- Pending location updates array
LocationCache = {}

-- Main api POST function
local function SendLocations()
    PerformHttpRequest(apiURL, function(statusCode, res, headers) 
    end, "POST", json.encode({['id'] = communityID,['key'] = apiKey,['type'] = 'UNIT_LOCATION',['data'] = LocationCache}), {["Content-Type"]="application/json"})
end

-- Main update thread sending api location update POST requests per the postTime interval
Citizen.CreateThread(function()
    while true do
        if #LocationCache > 0 then
            -- Make API request if 1 or more updates exist
            SendLocations()
            -- Clear pending location calls
            LocationCache = {}
        end
        -- Wait the (5000ms) delay to check for pending location calls
        Citizen.Wait(postTime)
    end
end)

-- Helper function to determine index of given steamHex
local function findIndex(steamHex)
    for i,loc in ipairs(LocationCache) do
        if loc.apiId == steamHex then
            return i
        end
    end
end

-- Event from client when location changes occur
RegisterServerEvent('cadSendLocation')
AddEventHandler('cadSendLocation', function(steamHex, currentLocation)
    -- Does this client location already exist in the pending location array?
    local index = findIndex(steamHex)
    if index then
        -- Location already in pending array -> Update
        LocationCache[index].location = currentLocation
    else
        -- Location does not exist in pending array -> Insert new location object
        table.insert(LocationCache, {['apiId'] = steamHex, ['location'] = currentLocation})
    end
end)