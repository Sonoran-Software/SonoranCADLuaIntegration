-- Main update thread sending api location update POST requests per the postTime interval
Citizen.CreateThread(function()
    Wait(0)
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
local function findIndex(identifier)
    for i,loc in ipairs(LocationCache) do
        if loc.apiId == identifier then
            return i
        end
    end
end

-- Event from client when location changes occur
RegisterServerEvent('cadSendLocation')
AddEventHandler('cadSendLocation', function(currentLocation)
    -- Does this client location already exist in the pending location array?
    local identifier = GetIdentifiers(source)[primaryIdentifier]
    if serverType == "esx" then
        identifier = ("%s:%s"):format(primaryIdentifier, identifier)
    end
    local index = findIndex(identifier)
    if index then
        -- Location already in pending array -> Update
        LocationCache[index].location = currentLocation
    else
        -- Location does not exist in pending array -> Insert new location object
        table.insert(LocationCache, {['apiId'] = identifier, ['location'] = currentLocation})
    end
end)