---------------------------------------------------------------------------
-- Config Options **EDIT THESE**
---------------------------------------------------------------------------
local communityID = ""
local apiKey = ""
local apiURL = 'https://sonorancad.com/api/emergency'
local postTime = 5000 --Recommended to stay above 5000ms
local serverType = "" -- Either specify "standalone" or "esx", "standalone" will use your Steam Name as the Caller ID, and "esx" will use "esx-identity" to use your character's name.

---------------------------------------------------------------------------
-- Server Event Handling **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------

        ---------------------------------
        -- Unit Panic
        ---------------------------------
-- shared function to send panic signals
function sendPanic(source)
    -- Determine steamHex identifier
    local steamHex = GetPlayerIdentifier(source, 0)
    -- Process panic POST request
    PerformHttpRequest(apiURL, function(statusCode, res, headers) 
    end, "POST", json.encode({['id'] = communityID, ['key'] = apiKey, ['type'] = 'UNIT_PANIC', ['data'] = {{ ['isPanic'] = true, ['apiId'] = steamHex}}}), {["Content-Type"]="application/json"})
end

-- Creation of a /panic command
RegisterCommand('panic', function(source, args, rawCommand)
    sendPanic(source)
end, false)

-- Client Panic request (to be used by other resources)
RegisterServerEvent('cadSendPanicApi')
AddEventHandler('cadSendPanicApi', function(source)
    sendPanic(source)
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
AddEventHandler('cadSendLocation', function(currentLocation)
    -- Does this client location already exist in the pending location array?
    local steamHex = GetPlayerIdentifier(source, 0)
    local index = findIndex(steamHex)
    if index then
        -- Location already in pending array -> Update
        LocationCache[index].location = currentLocation
    else
        -- Location does not exist in pending array -> Insert new location object
        table.insert(LocationCache, {['apiId'] = steamHex, ['location'] = currentLocation})
    end
end)

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- Helper function to get the ESX Identity object
local function getIdentity(source)
    local identifier = GetPlayerIdentifier(source, 0)
    local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    if result[1] ~= nil then
        local identity = result[1]

        return {
            identifier = identity['identifier'],
            firstname = identity['firstname'],
            lastname = identity['lastname'],
            dateofbirth = identity['dateofbirth'],
            sex = identity['sex'],
            height = identity['height']
        }
    else
        return nil
    end
end

        ---------------------------------
        -- Civilian 911
        ---------------------------------

RegisterCommand('911', function(source, args, rawCommand)
    -- Getting the user's Steam Hexidecimal and getting their location from the table.
    local identifier = GetPlayerIdentifier(source, 0)
    local index = findIndex(identifier)
    if index then
        callLocation = LocationCache[index].location
    else
        callLocation = 'Unknown'
    end 
    -- Checking if there are any description arguments.
    if args[1] then
        local description = table.concat(args, " ")
        -- Checking wether you have set it to standalone or esx.
        if serverType == "standalone" then
            -- Getting the Steam Name
            local standCaller = GetPlayerName(source)
            -- Sending the API event
            TriggerEvent('cadSendCallApi', true, standCaller, callLocation, description, source)
            -- Sending the user a message stating the call has been sent
            TriggerClientEvent('chatMessage', source, "^5^*[SonoranCAD]^r^7 Your call has been sent to the dispatch. Help is now on the way!")
        elseif serverType == "esx" then
            -- Getting the ESX Identity Name
            local name = getIdentity(source)
            esxCaller = name.firstname .. "  " .. name.lastname
            -- Sending the API event
            TriggerEvent('cadSendCallApi', true, esxCaller, callLocation, description, source)
            -- Sending the user a message stating the call has been sent
            TriggerClientEvent('chatMessage', source, "^5^*[SonoranCAD]^r^7 Your call has been sent to the dispatch. Help is now on the way!")
        end
    else
        -- Throwing an error message due to now call description stated
        TriggerClientEvent('chatMessage', source, "^8^*[Error]^r^7 You need to specify a call description.")
    end
end, false)

        ---------------------------------
        -- Civilian 311 Command
        ---------------------------------

RegisterCommand('311', function(source, args, rawCommand)
    -- Getting the user's Steam Hexidecimal and getting their location from the table.
    local identifier = GetPlayerIdentifier(source, 0)
    local index = findIndex(identifier)
    if index then
        callLocation = LocationCache[index].location
    else
        callLocation = 'Unknown'
    end 
    -- Checking if there are any description arguments.
    if args[1] then
        local description = table.concat(args, " ")
        -- Checking wether you have set it to standalone or esx.
        if serverType == "standalone" then
            -- Getting the Steam Name
            local standCaller = GetPlayerName(source)
            -- Sending the API event
            TriggerEvent('cadSendCallApi', false, standCaller, callLocation, description, source)
            -- Sending the user a message stating the call has been sent
            TriggerClientEvent('chatMessage', source, "^5^*[SonoranCAD]^r^7 Your call has been sent to the dispatch. Help is now on the way!")
        elseif serverType == "esx" then
            -- Getting the ESX Identity Name
            local name = getIdentity(source)
            esxCaller = name.firstname .. "  " .. name.lastname
            -- Sending the API event
            TriggerEvent('cadSendCallApi', false, esxCaller, callLocation, description, source)
            -- Sending the user a message stating the call has been sent
            TriggerClientEvent('chatMessage', source, "^5^*[SonoranCAD]^r^7 Your call has been sent to the dispatch. Help is now on the way!")
        end
    else
        -- Throwing an error message due to now call description stated
        TriggerClientEvent('chatMessage', source, "^8^*[Error]^r^7 You need to specify a call description.")
    end
end, false)

-- Client Call request
RegisterServerEvent('cadSendCallApi')
AddEventHandler('cadSendCallApi', function(emergency, caller, location, description)
    PerformHttpRequest(apiURL, function(statusCode, res, headers) 
    end, "POST", json.encode({['id'] = communityID, ['key'] = apiKey, ['type'] = 'CALL_911', ['data'] = {{['serverId'] = '1', ['isEmergency'] = emergency, ['caller'] = caller, ['location'] = location, ['description'] = description}}}), {["Content-Type"]="application/json"})
end)
