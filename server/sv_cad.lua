--[[
        SonoranCAD FiveM - A SonoranCAD integration for FiveM servers
              Copyright (C) 2020  Sonoran Software Systems LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program in the file "LICENSE".  If not, see <http://www.gnu.org/licenses/>.
]]

---------------------------------------------------------------------------
-- Reading Config options from config.json **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
local loadFile = LoadResourceFile(GetCurrentResourceName(), "./config.json")
local config = {}
config = json.decode(loadFile)

local communityID = config.communityId -- Sonoran CAD Community ID: Admin > Advanced > In-Game Integration > Web API
local apiKey = config.apiKey -- Sonoran CAD API Key: Admin > Advanced > In-Game Integration > Web API
local apiURL = config.apiUrl
local postTime = config.locationPostTime  -- Lowering this value will result in rate limiting, must be > 5000
local serverType = config.serverType -- Either specify "standalone" or "esx", "standalone" will use your Steam Name as the Caller ID, and "esx" will use "esx-identity" to use your character's name.
local jobsTracked = config.jobsTracked -- Job names that you want to be tracked on the live map

RegisterServerEvent('sonorancad:getConfig')
AddEventHandler('sonorancad:getConfig', function(source)
    local clientConfig = {serverType, jobsTracked}
    TriggerClientEvent('sonorancad:returnConfig', source, clientConfig)
end)
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
RegisterServerEvent('sonorancad:cadSendPanicApi')
AddEventHandler('sonorancad:cadSendPanicApi', function(source)
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
RegisterServerEvent('sonorancad:cadSendLocation')
AddEventHandler('sonorancad:cadSendLocation', function(source, currentLocation)
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

        ---------------------------------
        -- Civilian 911
        ---------------------------------

RegisterCommand('911', function(source, args, rawCommand)
    -- Getting the user's Steam Hexidecimal and getting their location from the table.
    local identifier = GetPlayerIdentifiers(source)[1]
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
            TriggerEvent('sonorancad:cadSendCallApi', true, standCaller, callLocation, description, source)
            -- Sending the user a message stating the call has been sent
            TriggerClientEvent('chatMessage', source, "^5^*[SonoranCAD]^r^7 Your call has been sent to the dispatch. Help is now on the way!")
        elseif serverType == "esx" then
            -- Getting the ESX Identity Name
            local name = getIdentity(source)
            esxCaller = name.firstname .. "  " .. name.lastname
            -- Sending the API event
            TriggerEvent('sonorancad:cadSendCallApi', true, esxCaller, callLocation, description, source)
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
    local identifier = GetPlayerIdentifiers(source)[1]
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
            TriggerEvent('sonorancad:cadSendCallApi', false, standCaller, callLocation, description, source)
            -- Sending the user a message stating the call has been sent
            TriggerClientEvent('chatMessage', source, "^5^*[SonoranCAD]^r^7 Your call has been sent to the dispatch. Help is now on the way!")
        elseif serverType == "esx" then
            -- Getting the ESX Identity Name
            local name = getIdentity(source)
            esxCaller = name.firstname .. "  " .. name.lastname
            -- Sending the API event
            TriggerEvent('sonorancad:cadSendCallApi', false, esxCaller, callLocation, description, source)
            -- Sending the user a message stating the call has been sent
            TriggerClientEvent('chatMessage', source, "^5^*[SonoranCAD]^r^7 Your call has been sent to the dispatch. Help is now on the way!")
        end
    else
        -- Throwing an error message due to now call description stated
        TriggerClientEvent('chatMessage', source, "^8^*[Error]^r^7 You need to specify a call description.")
    end
end, false)

-- Client Call request
RegisterServerEvent('sonorancad:cadSendCallApi')
AddEventHandler('sonorancad:cadSendCallApi', function(emergency, caller, location, description)
    PerformHttpRequest(apiURL, function(statusCode, res, headers) 
    end, "POST", json.encode({['id'] = communityID, ['key'] = apiKey, ['type'] = 'CALL_911', ['data'] = {{['serverId'] = '1', ['isEmergency'] = emergency, ['caller'] = caller, ['location'] = location, ['description'] = description}}}), {["Content-Type"]="application/json"})
end)
---------------------------------------------------------------------------
-- SonoranCAD Listener Event Handling (Recieves data from SonoranCAD)
---------------------------------------------------------------------------
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function getPlayerSource(identifier)
    local activePlayers = GetPlayers();
    print(dump(activePlayers))
    for i,player in pairs(activePlayers) do
        print('player ' .. tostring(player) .. ' - ' .. GetPlayerIdentifier(player))
        if GetPlayerIdentifier(player) == string.lower(identifier) then
            print("found player " .. tostring(player) .. " by identifier " .. identifier)
            return player
        end
    end
    print("ERROR: Could not find player with identifier " .. identifier)
end

RegisterServerEvent('sonorancad:recieveListenerData')
AddEventHandler('sonorancad:recieveListenerData', function(call)
    print('TRIGGERED LUA EVENT! :)')
    print(dump(call))
    if call.type == "UNIT_UPDATE" then
        targetPlayer = getPlayerSource(call.data.apiId)
        TriggerClientEvent('sonorancad:livemap:unitUpdate', targetPlayer, call.data)
    end
end)