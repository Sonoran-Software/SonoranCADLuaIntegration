--[[
    Sonaran CAD Plugins

    Plugin Name: callcommands
    Creator: SonoranCAD
    Description: Implements 311/511/911 commands
]]

local pluginConfig = Config.plugins["callcommands"]

-- 911/311 Handler
function HandleCivilianCall(type, source, args, rawCommand)
    -- Getting the user's Steam Hexidecimal and getting their location from the table.
    local isEmergency = type == "911" and true or false
    local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
    local index = findIndex(identifier)
    local callLocation = LocationCache[source] ~= nil and LocationCache[source].location or 'Unknown'
    -- Checking if there are any description arguments.
    if args[1] then
        local description = table.concat(args, " ")
        if type == "511" then
            description = "(511 CALL) "..description
        end
        local caller = nil
        -- Checking wether you have set it to standalone or esx.
        if Config.serverType == "standalone" then
            -- Getting the Steam Name
            caller = GetPlayerName(source) 
        elseif Config.serverType == "esx" then
            -- Getting the ESX Identity Name
            local name = getIdentity(source)
            if name ~= nil then
                caller = ("%s %s"):format(name.firstname,name.lastname)
            else
                debugPrint("[SenoranCAD] Warning: Unable to get a proper identity for the caller. Falling back to player name.")
                caller = GetPlayerName(source)
            end
        else
            print("ERROR: Improper serverType was specified in configuration. Please check it!")
            return
        end
        -- Sending the API event
        TriggerEvent('cadSendCallApi', isEmergency, caller, callLocation, description, source)
        -- Sending the user a message stating the call has been sent
        TriggerClientEvent("chat:addMessage", source, {args = {"^0^5^*[SonoranCAD]^r ", "^7Your call has been sent to dispatch. Help is on the way!"}})
    else
        -- Throwing an error message due to now call description stated
        TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1Error ^0] ", "You need to specify a call description."}})
    end
end

CreateThread(function()
    if pluginConfig.enable911 then
        RegisterCommand('911', function(source, args, rawCommand)
            HandleCivilianCall("911", source, args, rawCommand)
        end, false)
    end
    if pluginConfig.enable511 then
        RegisterCommand('511', function(source, args, rawCommand)
            HandleCivilianCall("511", source, args, rawCommand)
        end, false)
    end
    if pluginConfig.enable311 then
        RegisterCommand('311', function(source, args, rawCommand)
            HandleCivilianCall("311", source, args, rawCommand)
        end, false)
    end
    if pluginConfig.enablePanic then
        RegisterCommand('panic', function(source, args, rawCommand)
            sendPanic(source)
        end, false)
        -- Client Panic request (to be used by other resources)
        RegisterServerEvent('cadSendPanicApi')
        AddEventHandler('cadSendPanicApi', function(source)
            sendPanic(source)
        end)
    end

end)

-- Client Call request
RegisterServerEvent('cadSendCallApi')
AddEventHandler('cadSendCallApi', function(emergency, caller, location, description, source)
    -- send an event to be consumed by other resources
    TriggerEvent("cadIncomingCall", emergency, caller, location, description, source)
    if Config.apiSendEnabled then
        local data = {['serverId'] = Config.serverId, ['isEmergency'] = emergency, ['caller'] = caller, ['location'] = location, ['description'] = description}
        debugLog("sending call!")
        performApiRequest({data}, 'CALL_911', function() end)
    else
        debugPrint("[SonoranCAD] API sending is disabled. Incoming call ignored.")
    end
end)

---------------------------------
-- Unit Panic
---------------------------------
-- shared function to send panic signals
function sendPanic(source)
    -- Determine identifier
    local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
    -- Process panic POST request
    performApiRequest({{['isPanic'] = true, ['apiId'] = identifier}}, 'UNIT_PANIC', function() end)
end
