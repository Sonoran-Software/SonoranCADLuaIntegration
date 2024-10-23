--[[
    Sonaran CAD Plugins

    Plugin Name: dispatchnotify
    Creator: SonoranCAD
    Description: Show incoming 911 calls and allow units to attach to them.

    Put all server-side logic in this file.
]]

CreateThread(function() Config.LoadPlugin("dispatchnotify", function(pluginConfig)

if pluginConfig.enabled then

    local DISPATCH_TYPE = {"CALL_NEW", "CALL_EDIT", "CALL_CLOSE", "CALL_NOTE", "CALL_SELF_CLEAR"}
    local ORIGIN = {"CALLER", "RADIO_DISPATCH", "OBSERVED", "WALK_UP"}
    local STATUS = {"PENDING", "ACTIVE", "CLOSED"}

    local CallOriginMapping = {} -- callId => playerId
    local EmergencyToCallMapping = {} -- eCallId => CallId
    local CallNotes = {} -- callid -> notes table

    local MappedCalls = {} -- eCallId -> call object

    local function findCall(id)
        for idx, callId in pairs(EmergencyToCallMapping) do
            debugLog(("check %s = %s"):format(id, callId))
            if id == callId then
                return idx
            end
        end
        return nil
    end

    local function getCallFromOriginId(id)
        for k, call in pairs(GetCallCache()) do
            if call.dispatch ~= nil then
                if call.dispatch.metaData ~= nil then
                    debugLog(("check %s = %s"):format(id, call.dispatch.metaData.createdFromId))
                    if tonumber(call.dispatch.metaData.createdFromId) == tonumber(id) then
                        return call
                    end
                end
            end
        end
        return nil
    end

    local function SendMessage(type, source, message)
        debugLog(("Sending message to %s: %s"):format(source, message))
        if type == "dispatch" then
            TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^2Dispatch ^0] ", message}})
        elseif type == pluginConfig.emergencyCallType then
            TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1"..type.." ^0] ", message}})
        elseif type == pluginConfig.civilCallType then
            TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1"..type.." ^0] ", message}})
        elseif type == pluginConfig.dotCallType then
            TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1"..type.." ^0] ", message}})
        elseif type == "error" then
            TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1Error ^0] ", message}})
        elseif type == "debug" and Config.debugMode then
            TriggerClientEvent("chat:addMessage", source, {args = {"[ Debug ] ", message}})
        end
    end

    local function IsPlayerOnDuty(player)
        if pluginConfig.unitDutyMethod == "incad" then
            if GetUnitByPlayerId(tostring(player)) ~= nil then
                return true
            else
                return false
            end
        elseif pluginConfig.unitDutyMethod == "permissions" then
            return IsPlayerAceAllowed(player, "sonorancad.dispatchnotify")
        elseif pluginConfig.unitDutyMethod == "esxjob" then
            assert(isPluginLoaded("esxsupport") or isPluginLoaded("frameworksupport"), "frameworksupport plugin is required to use the esx/qb-core on duty method.")
            local job = GetCurrentJob(player)
            debugLog(("Player %s has job %s, return %s"):format(player, job, pluginConfig.esxJobsAllowed[GetCurrentJob(player)] ))
            if pluginConfig.esxJobsAllowed[GetCurrentJob(player)] then
                return true
            else
                return false
            end
        elseif pluginConfig.unitDutyMethod == "custom" then
            return unitDutyCustom(player)
        end
    end

    local function addCallNote(callId, note)
        if not CallNotes[callId] then
            local tbl = {}
            table.insert(tbl, note)
            CallNotes[callId] = tbl
        else
            table.insert(CallNotes[callId], note)
        end
    end

    local function clearNotes(callId)
        CallNotes[callId] = nil
    end

    local ActiveDispatchers = {}

    AddEventHandler("SonoranCAD::pushevents:UnitLogin", function(unit)
        if unit.isDispatch and pluginConfig.dispatchDisablesSelfResponse then
            pluginConfig.enableUnitResponse = false
            debugLog("Self dispatching disabled, dispatch is online")
            table.insert(ActiveDispatchers, unit.id)
        end
    end)

    AddEventHandler("SonoranCAD::pushevents:UnitLogout", function(id)
        local idx = nil
        for i, k in pairs(ActiveDispatchers) do
            if id == k then
                idx = i
            end
        end
        if idx ~= nil then
            table.remove(ActiveDispatchers, idx)
        end
        if pluginConfig.dispatchDisablesSelfResponse and #ActiveDispatchers < 1 then
            pluginConfig.enableUnitResponse = true
            debugLog("Self dispatching enabled, dispatch is offline")
        end
    end)

    --EVENT_911 TriggerEvent('SonoranCAD::pushevents:IncomingCadCall', body.data.call, body.data.apiIds, body.data.metaData)
    RegisterServerEvent("SonoranCAD::pushevents:IncomingCadCall")
    AddEventHandler("SonoranCAD::pushevents:IncomingCadCall", function(call, metadata, apiIds)
        if metadata ~= nil and metadata.callerPlayerId ~= nil then
            CallOriginMapping[call.callId] = metadata.callerPlayerId
        end
        if pluginConfig.enableUnitNotify then
            local type = call.emergency and pluginConfig.civilCallType or pluginConfig.emergencyCallType
            local message = pluginConfig.incomingCallMessage:gsub("{caller}", call.caller):gsub("{location}", call.location):gsub("{description}", call.description):gsub("{callId}", call.callId):gsub("{command}", pluginConfig.respondCommandName)
            for i = 0, GetNumPlayerIndices()-1 do
                local player = GetPlayerFromIndex(i)
                local unit = GetUnitByPlayerId(player)
                if IsPlayerOnDuty(player) then
                    if pluginConfig.unitNotifyMethod == "chat" then
                        SendMessage(type, player, message)
                    elseif pluginConfig.unitNotifyMethod == "pnotify" then
                        TriggerClientEvent("pNotify:SendNotification", player, {
                            text = message,
                            type = "error",
                            layout = "bottomcenter",
                            timeout = "10000"
                        })
                    elseif pluginConfig.unitNotifyMethod == "custom" then
                        TriggerClientEvent("SonoranCAD::dispatchnotify:IncomingCallNotify", player, message)
                    end
                else
                    debugLog(("Ignore player %s, not on duty"):format(player))
                end
            end
        end
    end)

    RegisterServerEvent("SonoranCAD::callcommands:EmergencyCallAdd")
    AddEventHandler("SonoranCAD::callcommands:EmergencyCallAdd", function(playerId, callId)
        CallOriginMapping[tonumber(callId)] = playerId
    end)

    --Officer response
    registerApiType("NEW_DISPATCH", "emergency")
    registerApiType("ATTACH_UNIT", "emergency")
    registerApiType("REMOVE_911", "emergency")
    registerApiType("SET_CALL_POSTAL", "emergency")
    RegisterCommand(pluginConfig.respondCommandName, function(source, args, rawCommand)
        local source = tonumber(source)
        local callId = args[1]
        if callId == nil then
            SendMessage("error", source, "Call ID must be specified.")
            return
        end
        callId = tonumber(callId)
        if not pluginConfig.enableUnitResponse then
            SendMessage("error", source, "Self dispatching is disabled.")
            return
        end
        if not IsPlayerOnDuty(source) then
            SendMessage("error", source, "You must be on duty to use this command.")
            return
        end
        if not GetUnitByPlayerId(source) then
            SendMessage("error", source, "Due to system limitations, you must be logged into the CAD to self attach.")
            return
        end
        
        -- Fetch if call hasn't been responded to yet
        local call = GetEmergencyCache()[callId]
        if call == nil then
            -- Call responded, grab from mapping
            call = MappedCalls[callId]
        end
        if call == nil then
            -- not in mapping, check call cache
            call = getCallFromOriginId(callId)
        end
        if call == nil then
            SendMessage("error", source, "Could not find that call ID")
            return
        elseif call.dispatch ~= nil then
            call = call.dispatch
        end
        local callerPlayerId = nil
        local originCall = nil
        if call.metaData ~= nil then
            callerPlayerId = call.metaData.callerPlayerId
            originCall = call.metaData.createdFromId
        end
        if call.metaData ~= nil and callerPlayerId == nil then
            debugLog("failed to find caller info")
        end
        local identifiers = GetIdentifiers(source)[Config.primaryIdentifier]
        if originCall == nil then
            -- no mapped call, create a new one
            debugLog(("Creating new call request...(no mapped call for %s)"):format(callId))
            local postal = ""
            if isPluginLoaded("postals") and callerPlayerId ~= nil then
                if PostalsCache[tonumber(callerPlayerId)] ~= nil then
                    postal = PostalsCache[tonumber(callerPlayerId)]
                else
                    debugLog("Failed to obtain postal. "..json.encode(PostalsCache))
                    return
                end
            end
            if call.metaData ~= nil and call.metaData.useCallLocation == "true" and call.metaData.callPostal ~= nil then
                postal = call.metaData.callPostal
            end
            local title = "OFFICER RESPONSE - "..call.callId
            if pluginConfig.callTitle ~= nil then
                title = pluginConfig.callTitle.." - "..call.callId
            end
            metaData = {callerPlayerId = callerPlayerId, createdFromId = call.callId }
            if call.metaData ~= nil then
                for k, v in pairs(call.metaData) do
                    metaData[k] = v
                end
            end
            if LocationCache[source] ~= nil and metaData['x'] == nil then
                metaData['x'] = LocationCache[source].coordinates.x
                metaData['y'] = LocationCache[source].coordinates.y
                metaData['z'] = LocationCache[source].coordinates.z
            end
            local payload = {   serverId = Config.serverId,
                                origin = 0, 
                                status = 1, 
                                priority = 2,
                                block = "",
                                code = "",
                                postal = (postal ~= nil and postal or ""),
                                address = (call.location ~= nil and call.location or "Unknown"), 
                                title = title,
                                description = (call.description ~= nil and call.description or ""), 
                                isEmergency = call.isEmergency,
                                notes = {
                                    {time = '00:00:00', label = 'Dispatch', type = 'text', content = 'Officer Responding'}
                                },
                                metaData = metaData,
                                units = { identifiers }
            }
            performApiRequest({payload}, "NEW_DISPATCH", function(response)
                debugLog("Call creation OK")
                if response:match("NEW DISPATCH CREATED - ID:") then
                    TriggerEvent("SonoranCAD::dispatchnotify:UnitRespond", source, response:match("%d+"))
                    EmergencyToCallMapping[call.callId] = tonumber(response:match("%d+"))
                end
                -- remove the 911 call
                local payload = { serverId = Config.serverId, callId = call.callId }
                performApiRequest({payload}, "REMOVE_911", function(resp)
                    debugLog("Remove status: "..tostring(resp))
                end)
            end)
        else
            -- Call already exists
            debugLog("Found Call. Attaching!")
            local data = {callId = call.callId, units = {identifiers}, serverId = Config.serverId}
            performApiRequest({data}, "ATTACH_UNIT", function(res)
                debugLog("Attach OK: "..tostring(res))
                SendMessage("debug", source, "You have been attached to the call.")
            end)
        end
    end)

    RegisterNetEvent("SonoranCAD::dispatchnotify:CallAttach")
    RegisterNetEvent("SonoranCAD::dispatchnotify:CallDetach")
    RegisterServerEvent("SonoranCAD::pushevents:UnitAttach")
    AddEventHandler("SonoranCAD::pushevents:UnitAttach", function(call, unit)
        debugLog("hello, unit attach! "..json.encode(call))
        local callerId = nil
        if call.dispatch.metaData ~= nil and call.dispatch.metaData.callerPlayerId ~= nil then
            debugLog("set caller ID "..call.dispatch.metaData.callerPlayerId)
            callerId = call.dispatch.metaData.callerPlayerId
        end
        local officerId = GetSourceByApiId(unit.data.apiIds)
        if officerId ~= nil then
            SendMessage("dispatch", officerId, ("You are now attached to call ^4%s^0. Description: ^4%s^0"):format(call.dispatch.callId, call.dispatch.description))
            TriggerClientEvent("SonoranCAD::dispatchnotify:CallAttach", officerId, call.dispatch.callId)
            local callerLocation = nil
            if callerId ~= nil then
                callerLocation = findPlayerLocation(callerId)
            end
            if callerLocation == nil or call.dispatch.metaData.useCallLocation then
                callerLocation = {x=call.dispatch.metaData.x, y=call.dispatch.metaData.y, z=call.dispatch.metaData.z}
            end
            debugLog(("Sending location data %s to %s (call data: %s)"):format(json.encode(callerLocation), officerId, json.encode(call)))
            if pluginConfig.waypointType == "exact" and callerLocation ~= nil then
                TriggerClientEvent("SonoranCAD::dispatchnotify:SetLocation", officerId, callerLocation)
            elseif pluginConfig.waypointType == "postal" or pluginConfig.waypointFallbackEnabled then
                if call.dispatch.postal ~= nil and call.dispatch.postal ~= "" then
                    TriggerClientEvent("SonoranCAD::dispatchnotify:SetGps", officerId, call.dispatch.postal)
                    if call.dispatch.metaData ~= nil and call.dispatch.metaData.trackPrimary == "True" then
                        if GetSourceByApiId(GetUnitCache()[call.dispatch.idents[1]].data.apiIds) == officerId then
                            TriggerClientEvent("SonoranCAD::dispatchnotify:BeginTracking", officerId, call.dispatch.callId)
                        end
                    end
                end
            else
                local lc = LocationCache[callerId]
                if lc == nil then
                    lc = { ['error'] = "locationcache is nil"}
                end
                debugLog(("LOCATION SETTING: Failed to send client location. - waypointType: %s - callerId: %s - LocationCache: %s"):format(pluginConfig.waypointType, callerId, json.encode(lc)))
            end
        else
            debugLog("failed to find unit "..json.encode(unit))
        end
        if pluginConfig.enableCallerNotify and callerId ~= nil and call.dispatch.metaData.silentAlert == "false" then
            if pluginConfig.callerNotifyMethod == "chat" then
                SendMessage("dispatch", callerId, pluginConfig.notifyMessage:gsub("{officer}", unit.data.name))
            elseif pluginConfig.callerNotifyMethod == "pnotify" then
                TriggerClientEvent("pNotify:SendNotification", callerId, {
                    text = pluginConfig.notifyMessage:gsub("{officer}", unit.data.name),
                    type = "error",
                    layout = "bottomcenter",
                    timeout = "10000"
                })
            elseif pluginConfig.callerNotifyMethod == "custom" then
                TriggerEvent("SonoranCAD::dispatchnotify:UnitAttach", call.dispatch, callerId, officerId, unit.data.name)
            end
        else
            debugLog(("pluginConfig.enableCallerNotify == %s and %s ~= nil and not %s == 'false'"):format(pluginConfig.enableCallerNotify, callerId, call.dispatch.metaData.silentAlert))
        end
    end)

    RegisterServerEvent("SonoranCAD::pushevents:DispatchEvent")
    AddEventHandler("SonoranCAD::pushevents:DispatchEvent", function(data)
        local dispatchType = data.dispatch_type
        local dispatchData = data.dispatch
        local metaData = data.dispatch.metaData
        if dispatchType ~= tostring(dispatchType) then
            -- hmm, expected a string, got a number
            dispatchType = DISPATCH_TYPE[data.dispatch_type+1]
        end
        local switch = {
            ["CALL_NEW"] = function()
                debugLog("CALL_NEW fired "..json.encode(dispatchData))
                local emergencyId = dispatchData.metaData.createdFromId
                for k, id in pairs(dispatchData.idents) do
                    local unit = GetUnitCache()[GetUnitById(id)]
                    if not unit then
                        debugLog("Not sending attach, unit not online")
                    else
                        local officerId = GetSourceByApiId(unit.data.apiIds)
                        TriggerEvent("SonoranCAD::pushevents:UnitAttach", data, unit)
                    end
                end
            end,
            ["CALL_CLOSE"] = function() 
                debugLog("CALL_CLOSE fired "..json.encode(dispatchData))
                if dispatchData == nil or dispatchData.dispatch == nil then
                    debugLog("nil value detected, ignore it")
                    return
                end
                local cache = GetCallCache()[dispatchData.dispatch.callId]
                if cache.units ~= nil then
                    for k, v in pairs(cache.units) do
                        local officerId = GetUnitCache()[GetUnitById(v.id)]
                        if officerId ~= nil then
                            TriggerClientEvent("SonoranCAD::dispatchnotify:CallClosed", officerId, cache.callId)
                        end
                    end
                end
                clearNotes(dispatchData.dispatch.callId)
            end,
            ["CALL_NOTE"] = function() 
                TriggerEvent("SonoranCAD::dispatchnotify:CallNote", dispatchData.callId, dispatchData.notes)
            end,
            ["CALL_SELF_CLEAR"] = function() 
                TriggerEvent("SonoranCAD::dispatchnotify:CallSelfClear", dispatchData.units)
            end
        }
        if switch[dispatchType] then
            switch[dispatchType]()
        end
    end)

    AddEventHandler("SonoranCAD::pushevents:DispatchEdit", function(before, after)
        if before.dispatch.primary ~= after.dispatch.primary then
            -- Primary Unit Updated, remove tracking from old unit.
            local unit = GetUnitCache()[GetUnitById(before.dispatch.primary)]
            if unit ~= nil then 
                local officerId = GetSourceByApiId(unit.data.apiIds)
                TriggerClientEvent("SonoranCAD::dispatchnotify:StopTracking", officerId)
            end
        end
        if before.dispatch.primary ~= after.dispatch.primary or before.dispatch.trackPrimary ~= after.dispatch.trackPrimary then
            TriggerEvent("SonoranCAD::dispatchnotify:CallEdit:Tracking", after.dispatch.callId, after.dispatch.trackPrimary, after.dispatch.primary)
        end
        if before.dispatch.postal ~= after.dispatch.postal then
            TriggerEvent("SonoranCAD::dispatchnotify:CallEdit:Postal", after.dispatch.callId, after.dispatch.postal)
        end
        if before.address ~= after.address then
            TriggerEvent("SonoranCAD::dispatchnotify:CallEdit:Address", after.dispatch.callId, after.dispatch.address)
        end
    end)

    AddEventHandler("SonoranCAD::dispatchnotify:CallEdit:Tracking", function(callId, tracking, primary)
        local call = GetCallCache()[callId]
        assert(call ~= nil, "Call not found, failed to process.")
        local unit = GetUnitCache()[GetUnitById(primary)]
        local officerId = GetSourceByApiId(unit.data.apiIds)
        if tracking then
            TriggerClientEvent("SonoranCAD::dispatchnotify:BeginTracking", officerId, callId)
        else
            TriggerClientEvent("SonoranCAD::dispatchnotify:StopTracking", officerId)
        end
    end)       


    AddEventHandler("SonoranCAD::pushevents:UnitDetach", function(call, unit)
        local officerId = GetSourceByApiId(unit.data.apiIds)
        if GetCallCache()[call.dispatch.callId] == nil then
            debugLog("Ignore unit detach, call doesn't exist")
            return
        end
        if officerId ~= nil and call ~= nil and call.dispatch.metaData ~= nil then
            if call.dispatch.metaData.trackPrimary then
                TriggerClientEvent("SonoranCAD::dispatchnotify:StopTracking", officerId)
            end
            TriggerClientEvent("SonoranCAD::dispatchnotify:CallDetach", officerId, call.dispatch.callId)
            SendMessage("dispatch", officerId, ("You were detached from call %s."):format(call.dispatch.callId))
        end
    end)

    AddEventHandler("SonoranCAD::dispatchnotify:CallEdit:Postal", function(callId, postal)
        local call = GetCallCache()[callId]
        assert(call ~= nil, "Call not found, failed to process.")
        if call.dispatch.idents == nil then
            debugLog("no units attached "..json.encode(call))
            return
        end
        for k, id in pairs(call.dispatch.idents) do
            local unit = GetUnitCache()[GetUnitById(id)]
            if unit == nil then
                debugLog(("Unit was nil, requested %s, cache is: %s"):format(id, GetUnitCache()))
                return
            end
            local officerId = GetSourceByApiId(unit.data.apiIds)
            if officerId ~= nil then
                TriggerClientEvent("SonoranCAD::dispatchnotify:SetGps", officerId, postal)
            else
                debugLog("couldn't find officer")
            end
        end
    end)
    RegisterServerEvent("SonoranCAD::dispatchnotify:UpdateCallPostal")
    AddEventHandler("SonoranCAD::dispatchnotify:UpdateCallPostal", function(clpostal, callid)
        local data = {}
        data[1] = {
            callId = callid,
            postal = clpostal,
            serverId = Config.serverId
        }
        performApiRequest(data, 'SET_CALL_POSTAL', function() end)
    end)

    AddEventHandler("SonoranCAD::pushevents:DispatchNote", function(call, data)
        if not pluginConfig.sendNotesToUnits then
            return
        end
        if not call then
            debugLog(("Failed to find call: %s"):format(json.encode(data)))
            return
        end
        call = call.dispatch
        -- add note to cache
        addCallNote(data.callId, data.note)
        debugLog(("Incoming note for ID %s, call: %s"):format(data.callId, json.encode(call)))
        local noteContent = type(data.note) == 'table' and data.note.content or data.note
        if call.idents ~= nil and type(noteContent) == 'string' then
            for _, ident in pairs(call.idents) do
                local officerId = GetUnitCache()[GetUnitById(ident)]
                if officerId ~= nil then
                    local patterns = { ["{callid}"] = data.callId, ["{note}"] = noteContent}
                    local message = pluginConfig.noteMessage
                    for k, v in pairs(patterns) do
                        message = message:gsub(k, v)
                    end
                    if pluginConfig.noteNotifyMethod == "chat" then
                        SendMessage("dispatch", officerId, message)
                    elseif pluginConfig.noteNotifyMethod == "pnotify" then
                        TriggerClientEvent("pNotify:SendNotification", officerId, {
                            text = message,
                            type = "info",
                            layout = "bottomcenter",
                            timeout = "10000"
                        })
                    else
                        TriggerClientEvent("SonoranCAD::dispatchnotify:NewCallNote", officerId, data)
                    end
                else
                    debugLog(("Skipping officer %s, not available"):format(ident))
                end
            end
        end
    end)

    registerApiType("ADD_CALL_NOTE", "emergency")
    RegisterNetEvent("SonoranCAD::dispatchnotify:AddNoteToCall")
    AddEventHandler("SonoranCAD::dispatchnotify:AddNoteToCall", function(callId, note)
        local source = source
        debugLog(("Got note add request from %s, call id %s: %s"):format(source, callId, note))
        local call = GetCallCache()[callId]
        if call == nil then
            TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^2Dispatch ^0] ", "Unable to find call."}})
        else
            local payload = { serverId = Config.serverId, note = note, callId = callId }
            performApiRequest({payload}, "ADD_CALL_NOTE", function(res) end)
        end
    end)
    if isPluginLoaded("wraithv2") then
        AddEventHandler("wk:onPlateLocked", function(cam, plate, index)
            local plate = plate:match("^%s*(.-)%s*$")
            if IsPlayerOnDuty(source) then
                TriggerClientEvent("SonoranCAD::dispatchnotify:PlateLock", source, plate)
            end
        end)
    else
        debugLog("Not loading radar lock as wraith plugin is not loaded")
    end

    AddEventHandler("SonoranCAD::pushevents:UnitUpdate", function(unit, status)
        local u = GetUnitCache()[unit]
        if u then
            local player = GetSourceByApiId(u.data.apiIds)
            if player then
                TriggerClientEvent("SonoranCAD::dispatchnotify:UnsetGps", player)
            end
        end
    end)
    
end

end) end)
