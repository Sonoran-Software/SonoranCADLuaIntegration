--[[
    Sonaran CAD Plugins

    Plugin Name: callcommands
    Creator: SonoranCAD
    Description: Implements 311/511/911 commands
]] CreateThread(function()
    Config.LoadPlugin("callcommands", function(pluginConfig)
        if pluginConfig.enabled then

            local random = math.random
            local function uuid()
                math.randomseed(os.time())
                local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
                return string.gsub(template, '[xy]', function(c)
                    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
                    return string.format('%x', v)
                end)
            end
            -- 911/311 Handler
            function HandleCivilianCall(type, typeObj, source, args, rawCommand)
                local isEmergency = typeObj.isEmergency
                local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
                local callLocation = LocationCache[source] ~= nil and LocationCache[source].location or 'Unknown'
                -- Checking if there are any description arguments.
                if args[1] then
                    local description = table.concat(args, " ")
                    if typeObj.descriptionPrefix ~= "" then
                        description = typeObj.descriptionPrefix .. " " .. description
                    end
                    local caller = nil
                    if isPluginLoaded("esxsupport") or isPluginLoaded("frameworksupport") then
                        -- Getting the ESX Identity Name
                        GetIdentity(source, function(identity)
                            if identity.name ~= nil then
                                caller = identity.name
                            else
                                caller = GetPlayerName(source)
                                debugLog("Unable to get player name from ESX. Falled back to in-game name.")
                            end
                        end)
                        while caller == nil do
                            Wait(10)
                        end
                    else
                        caller = GetPlayerName(source)
                    end
                    -- Sending the API event
                    TriggerEvent('SonoranCAD::callcommands:SendCallApi', isEmergency, caller, callLocation,
                        description, source, nil, nil, type)
                    -- Sending the user a message stating the call has been sent
                    TriggerClientEvent("chat:addMessage", source, {
                        args = {"^0^5^*[SonoranCAD]^r ",
                                "^7Your call has been sent to dispatch. Help is on the way!"}
                    })
                else
                    -- Throwing an error message due to now call description stated
                    TriggerClientEvent("chat:addMessage", source, {
                        args = {"^0[ ^1Error ^0] ", "You need to specify a call description."}
                    })
                end
            end

            CreateThread(function()
                for _, call in pairs(pluginConfig.callTypes) do
                    RegisterCommand(call.command, function(source, args, rawCommand)
                        HandleCivilianCall(call.command, call, source, args, rawCommand)
                    end)
                end
                if pluginConfig.enablePanic then
                    RegisterCommand('panic', function(source, args, rawCommand)
                        sendPanic(source, true)
                    end, false)
                    -- Client Panic request (to be used by other resources)
                    RegisterNetEvent('SonoranCAD::callcommands:SendPanicApi')
                    AddEventHandler('SonoranCAD::callcommands:SendPanicApi', function()
                        sendPanic(source, true)
                    end)
                end

            end)

            --[[
            data: valid key/value pairs:
                title = title of call (required)
                description = description of call (required)
                block = block field of call
                code = 10 code of call
                origin = ID of origin, default is 0 (Caller)
                status = usually 1 (pending)
                priority = Priority of call, default is 2
                address = location of call (required)
                postal = call postal
                isEmergency = (true/false) whether this is a 911 call, default true
                notes = array of notes to add to the call when created
                metaData = key/value pair of metadata to attach to the call
                units = array of unit API IDs to auto-attach
        ]]
            AddEventHandler("SonoranCAD::callcommands:CreateCall", function(data)
                local payload = {
                    serverId = Config.serverId,
                    origin = 0,
                    status = 1,
                    priority = 2,
                    block = "",
                    code = "",
                    postal = "",
                    address = "",
                    title = "",
                    description = "",
                    isEmergency = true,
                    notes = {},
                    metaData = {},
                    units = {}
                }
                for k, v in pairs(data) do
                    payload[k] = v
                end
                performApiRequest({payload}, "NEW_DISPATCH", function(response)
                    if response:match("NEW DISPATCH CREATED - ID:") then
                        TriggerEvent("SonoranCAD::callcommands:CallCreated", response:match("%d+"))
                    else
                        warnLog("Call creation returned unexpected response: " .. tostring(response))
                    end
                end)
            end)

            AddEventHandler("SonoranCAD::callcommands:SendPanic", function(playerId)
                local id = GetIdentifiers(playerId)[Config.primaryIdentifier]
                if id then
                    performApiRequest({{
                        ['isPanic'] = true,
                        ['apiId'] = id
                    }}, 'UNIT_PANIC', function()
                        debugLog(("Sent panic event for %s"):format(id))
                        TriggerEvent("SonoranCAD::callcommands:PanicSent", playerId)
                    end)
                end
            end)

            -- Client Call request
            RegisterServerEvent('SonoranCAD::callcommands:SendCallApi')
            AddEventHandler('SonoranCAD::callcommands:SendCallApi',
                function(emergency, caller, location, description, source, silenceAlert, useCallLocation, t)
                    local postal = ""
                    if location == '' then
                        location = LocationCache[source] ~= nil and LocationCache[source].location or 'Unknown'
                    elseif type(location) == 'vector3' then
                        if isPluginLoaded("postals") then
                            postal = getPostalFromVector3(location)
                        else
                            postal = "Unknown"
                        end
                    end
                    -- send an event to be consumed by other resources
                    local uid = uuid()
                    TriggerEvent("SonoranCAD::callcommands:cadIncomingCall", emergency, caller, location,
                        description, source, uid, t)
                    if silenceAlert == nil then
                        silenceAlert = false
                    end
                    if useCallLocation == nil then
                        useCallLocation = false
                    end
                    if isPluginLoaded("postals") and PostalsCache ~= nil and type(location) ~= 'vector3' then
                        postal = PostalsCache[source]
                    end
                    if Config.apiSendEnabled then
                        local data = {
                            ['serverId'] = Config.serverId,
                            ['isEmergency'] = emergency,
                            ['caller'] = caller,
                            ['location'] = location,
                            ['description'] = description,
                            ['metaData'] = {
                                ['callerPlayerId'] = source,
                                ['callerApiId'] = GetIdentifiers(source)[Config.primaryIdentifier],
                                ['uuid'] = uid,
                                ['silentAlert'] = silenceAlert,
                                ['useCallLocation'] = useCallLocation,
                                ['postal'] = postal
                            }
                        }
                        if LocationCache[source] ~= nil then
                            data['metaData']['x'] = LocationCache[source].coordinates.x
                            data['metaData']['y'] = LocationCache[source].coordinates.y
                            data['metaData']['z'] = LocationCache[source].coordinates.z
                        elseif type(location) == "vector3" and pluginConfig.usePositionForMetadata then
                            data['metaData']['x'] = location.x
                            data['metaData']['y'] = location.y
                            data['metaData']['z'] = location.z
                        else
                            debugLog("Warning: location cache was nil, not sending position")
                        end
                        debugLog("sending call!")
                        performApiRequest({data}, 'CALL_911', function(response)
                            if response:match("EMERGENCY CALL ADDED ID:") then
                                TriggerEvent("SonoranCAD::callcommands:EmergencyCallAdd", source,
                                    response:match("%d+"))
                            end
                        end)
                    else
                        debugPrint("[SonoranCAD] API sending is disabled. Incoming call ignored.")
                    end
                end)

            ---------------------------------
            -- Unit Panic
            ---------------------------------
            -- shared function to send panic signals

            -- TriggerEvent("SonoranCAD::pushevents:UnitPanic", unit, body.data.identId)
            AddEventHandler("SonoranCAD::pushevents:UnitPanic", function(unit, ident, isPanic)
                debugLog(("triggered panic %s"):format(json.encode(unit)))
                if not isPanic then
                    return debugLog("ignore panic, was toggled off")
                end
                local unit = GetUnitCache()[GetUnitById(ident)]
                if unit then
                    local player = GetSourceByApiId(unit.data.apiIds)
                    if player then
                        sendPanic(player)
                    end
                end
            end)
            function sendPanic(source, ispanicrequest)
                -- Determine identifier
                local source = tostring(source)
                local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
                -- Process panic POST request
                if pluginConfig.addPanicCall and not ispanicrequest then
                    local unit = GetUnitByPlayerId(source)
                    if not unit then
                        debugLog("Caller not a unit, ignoring.")
                        return
                    end
                    local postal = ""
                    if isPluginLoaded("postals") and PostalsCache[source] ~= nil then
                        postal = PostalsCache[source]
                    else
                        debugLog("postal is nil?!")
                    end
                    local data = {
                        ['serverId'] = Config.serverId,
                        ['isEmergency'] = true,
                        ['caller'] = unit.data.name,
                        ['location'] = unit.location,
                        ['description'] = ("Unit %s has pressed their panic button!"):format(unit.data.unitNum),
                        ['metaData'] = {
                            ['callerPlayerId'] = source,
                            ['callerApiId'] = GetIdentifiers(source)[Config.primaryIdentifier],
                            ['uuid'] = uuid(),
                            ['silentAlert'] = false,
                            ['useCallLocation'] = false,
                            ['postal'] = postal
                        }
                    }
                    if LocationCache[source] ~= nil then
                        data['metaData']['x'] = LocationCache[source].coordinates.x
                        data['metaData']['y'] = LocationCache[source].coordinates.y
                        data['metaData']['z'] = LocationCache[source].coordinates.z
                    else
                        debugLog("Warning: location cache was nil, not sending position")
                    end
                    debugLog(("perform panic request %s"):format(json.encode(data)))
                    performApiRequest({data}, 'CALL_911', function(resp)
                        debugLog(resp)
                    end)
                end
                if ispanicrequest then
                    performApiRequest({{
                        ['isPanic'] = true,
                        ['apiId'] = identifier
                    }}, 'UNIT_PANIC', function()
                    end)
                end
            end

        end
    end)
end)

