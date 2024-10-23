--[[
    Sonaran CAD Plugins

    Plugin Name: trafficstop
    Creator: SonoranCAD
    Description: Implements ts command
]]

CreateThread(function() Config.LoadPlugin("trafficstop", function(pluginConfig)

if pluginConfig.enabled then

    if pluginConfig.trafficCommand == nil then
        pluginConfig.trafficCommand = "ts"
    end

    registerApiType("NEW_DISPATCH", "emergency")

    -- Traffic Stop Handler
    function HandleTrafficStop(type, source, args, rawCommand)
        local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
        local index = findIndex(identifier)
        local origin = pluginConfig.origin 
        local status =  pluginConfig.status
        local priority =  pluginConfig.priority
        local address = LocationCache[source] ~= nil and LocationCache[source].location or 'Unknown'
        local postal = isPluginLoaded("postals") and getNearestPostal(source) or ""
        local title =  pluginConfig.title
        local code =  pluginConfig.code
        local units = {identifier}
        local tempNotes = {}
        local notesStr = ""
        address = address:gsub('%b[]', '')
        -- Checking if there are any description arguments.
        if args[1] then
            local description = table.concat(args, " ")
            if type == "ts" then
                description = "Traffic Stop - "..description
                if isPluginLoaded("wraithv2") and wraithLastPlates ~= nil then
                    if wraithLastPlates.locked ~= nil then
                        local plate = wraithLastPlates.locked.plate:gsub("%s+","")
                        table.insert(tempNotes, ("PLATE: %s"):format(plate))
                    end
                end
            end
            notesStr = table.concat(tempNotes, " ")
            local notes = {}
            if notesStr ~= "" then
                notes = {
                    { ['time'] = "00:00:00", ['label'] = "Dispatch", ['type'] = "text", ['content'] = notesStr }
                }
            end
            -- Sending the API event
            TriggerEvent('SonoranCAD::trafficstop:SendTrafficApi', origin, status, priority, address, postal, title, code, description, units, notes, source)
            -- Sending the user a message stating the call has been sent
            TriggerClientEvent("chat:addMessage", source, {args = {"^0^5^*[SonoranCAD]^r ", "^7Details regarding you traffic Stop have been added to CAD"}})
        else
            -- Throwing an error message due to now call description stated
            TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1Error ^0] ", "You need to specify Traffic Stop details (IE: vehicle Description)."}})
        end
    end

    RegisterCommand(pluginConfig.trafficCommand, function(source, args, rawCommand)
        HandleTrafficStop("ts", source, args, rawCommand)
    end, pluginConfig.usePermissions)

    -- Client TraficStop request
    RegisterServerEvent('SonoranCAD::trafficstop:SendTrafficApi')
    AddEventHandler('SonoranCAD::trafficstop:SendTrafficApi', function(origin, status, priority, address, postal, title, code, description, units, notes, source)
        -- send an event to be consumed by other resources
        TriggerEvent("SonoranCAD::trafficstop:cadIncomingTraffic", origin, status, priority, address, postal, title, code, description, units, notes, source)
        if Config.apiSendEnabled then
            local data = {
                ['serverId'] = Config.serverId, 
                ['origin'] = origin, 
                ['status'] = status, 
                ['priority'] = priority, 
                ['block'] = "", -- not used, but required
                ['postal'] = postal, --TODO
                ['address'] = address, 
                ['title'] = title, 
                ['code'] = code, 
                ['description'] = description, 
                ['units'] = units,
                ['notes'] = notes -- required
            }
            debugLog("sending Traffic Stop!")
            performApiRequest({data}, 'NEW_DISPATCH', function() end)
        else
            debugPrint("[SonoranCAD] API sending is disabled. Traffic Stop ignored.")
        end
    end)

end

end) end)
