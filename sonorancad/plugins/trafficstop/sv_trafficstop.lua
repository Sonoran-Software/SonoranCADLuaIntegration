--[[
    Sonaran CAD Plugins

    Plugin Name: trafficstop
    Creator: SonoranCAD
    Description: Implements ts command
]]

local pluginConfig = Config.plugins["trafficstop"]
registerApiType("NEW_DISPATCH", "emergency")
-- Traffic Stop Handler
function HandleTrafficStop(type, source, args, rawCommand)
    local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
    local index = findIndex(identifier)
    local origin = pluginConfig.orgin 
    local status =  pluginConfig.status
    local priority =  pluginConfig.priority
    local address = LocationCache[source] ~= nil and LocationCache[source].location or 'Unknown'
    local title =  pluginConfig.title
    local code =  pluginConfig.code
<<<<<<< HEAD
    local units = array(identifier)
=======
    local units = {identifier}
>>>>>>> 3069eab40b91408980f14f34e06c4f5db228f417
    -- Checking if there are any description arguments.
    if args[1] then
        local description = table.concat(args, " ")
        if type == "ts" then
            description = "Traffic Stop - "..description
        end
    

   
        -- Sending the API event
        TriggerEvent('SonoranCAD::trafficstop:SendTrafficApi', origin, status, priority, address, title, code, description, units, source)
        -- Sending the user a message stating the call has been sent
        TriggerClientEvent("chat:addMessage", source, {args = {"^0^5^*[SonoranCAD]^r ", "^7Details regarding you traffic Stop have been added to CAD"}})
    else
        -- Throwing an error message due to now call description stated
        TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1Error ^0] ", "You need to specify Traffic Stop details (IE: vehicle Description)."}})
    end
end

CreateThread(function()
   
    if pluginConfig.enablets then
        RegisterCommand('ts', function(source, args, rawCommand)
            HandleTrafficStop("ts", source, args, rawCommand)
        end, false)
    end
    

end)

-- Client TraficStop request
RegisterServerEvent('SonoranCAD::trafficstop:SendTrafficApi')
<<<<<<< HEAD
AddEventHandler('SonoranCAD::trafficstop:SendTrafficApii', function(origin, status, priority, address, title, code, description, units, source)
    -- send an event to be consumed by other resources
    TriggerEvent("SonoranCAD::trafficstop:cadIncomingTraffic", origin, status, priority, address, title, code, description, units, source)
    if Config.apiSendEnabled then
        local data = {['serverId'] = Config.serverId, 
        ['origin'] = origin, 
        ['status'] = status, 
        ['priority'] = priority, 
        ['address'] = address, 
        ['title'] = title, 
        ['code'] = code, 
        ['description'] = description, 
        ['units'] = units}
=======
AddEventHandler('SonoranCAD::trafficstop:SendTrafficApi', function(origin, status, priority, address, title, code, description, units, source)
    -- send an event to be consumed by other resources
    TriggerEvent("SonoranCAD::trafficstop:cadIncomingTraffic", origin, status, priority, address, title, code, description, units, source)
    if Config.apiSendEnabled then
        local data = {
            ['serverId'] = Config.serverId, 
            ['origin'] = origin, 
            ['status'] = status, 
            ['priority'] = priority, 
            ['block'] = "", -- not used, but required
            ['postal'] = "", --TODO
            ['address'] = address, 
            ['title'] = title, 
            ['code'] = code, 
            ['description'] = description, 
            ['units'] = units,
            ['notes'] = "" -- required
        }
>>>>>>> 3069eab40b91408980f14f34e06c4f5db228f417
        debugLog("sending Traffic Stop!")
        performApiRequest({data}, 'NEW_DISPATCH', function() end)
    else
        debugPrint("[SonoranCAD] API sending is disabled. Traffic Stop ignored.")
    end
end)


