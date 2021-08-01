local function getConfig()
    local config = LoadResourceFile(GetCurrentResourceName(), "config.json")
    return config
end



-- Event Handlers
local PushEventHandler = {
    EVENT_UNIT_STATUS = function(body)
        if (not body.data.identIds) then
            return false, "missing identIds"
        end
        local i = GetUnitById(body.data.identIds)
        if i then
            local unit = GetUnitCache()[i]
            unit.status = body.data.status
            SetUnitCache(body.data.identIds, unit)
            TriggerEvent('SonoranCAD::pushevents:UnitUpdate', unit, unit.status)
        else
            debugLog(("EVENT_UNIT_STATUS: Unknown unit, idents: %s"):format(json.encode(body.data.identIds)))
        end
        return true
    end,
    EVENT_UNIT_LOGIN = function(body)
        if (not body.data.unit.id) then
            return false, "missing ID"
        end
        local unit = body.data.unit
        debugLog("Got a unit: "..json.encode(unit))
        unit.isDispatch = body.data.isDispatch
        SetUnitCache(unit.id, unit)
        TriggerEvent('SonoranCAD::pushevents:UnitLogin', unit)
        return true
    end,
    EVENT_UNIT_LOGOUT = function(body)
        if (not body.data.identId) then
            return false, "missing identId"
        end
        debugLog("UNIT_LOGOUT: "..json.encode(body.data))
        TriggerEvent('SonoranCAD::pushevents:UnitLogout', body.data.identId)
        SetUnitCache(GetUnitById(body.data.identId), nil)
        return true
    end,
    EVENT_DISPATCH_NEW = function(body)
        SetCallCache(body.data.dispatch.callId, { dispatch_type = "CALL_NEW", dispatch = body.data.dispatch ~= nil and body.data.dispatch or body.data })
        TriggerEvent('SonoranCAD::pushevents:DispatchEvent', GetCallCache()[body.data.dispatch.callId])
        return true
    end,
    EVENT_DISPATCH_EDIT = function(body)
        TriggerEvent("SonoranCAD::pushevents:DispatchEdit", GetCallCache()[body.data.dispatch.callId], body.data)
        SetCallCache(body.data.dispatch.callId, { dispatch_type = "CALL_EDIT", dispatch = body.data.dispatch ~= nil and body.data.dispatch or body.data })
        TriggerEvent('SonoranCAD::pushevents:DispatchEvent', GetCallCache()[body.data.dispatch.callId])
        return true
    end,
    EVENT_DISPATCH_CLOSE = function(body)
        local call = GetCallCache()[body.data.callId]
        if call ~= nil then
            local d = { dispatch_type = "CALL_CLOSE", dispatch = call }
            SetCallCache(body.data.callId, body.data)
            TriggerEvent('SonoranCAD::pushevents:DispatchEvent', d)
            return true
        else
            debugLog(("Unknown call close (call ID %s), current cache: %s"):format(body.data.callId, json.encode(CallCache)))
            return false, "unknown call close"
        end
    end,
    EVENT_DISPATCH_NOTE = function(body)
        TriggerEvent('SonoranCAD::pushevents:DispatchNote', body.data)
    end,
    EVENT_DISPATCH_UNIT_ATTACH = function(body)
        -- fetch the call and unit data
        local call = GetCallCache()[body.data.callId]
        if body.data.ident ~= nil then
            local unit = GetUnitCache()[body.data.ident]
            if call and unit then
                TriggerEvent('SonoranCAD::pushevents:UnitAttach', call, unit)
            else
                debugLog("Attach failure, unknown call or unit")
            end
        elseif body.data.idents ~= nil then
            for i=1, #body.data.idents do
                local unit = GetUnitCache()[body.data.idents[i]]
                if call and unit then
                    TriggerEvent('SonoranCAD::pushevents:UnitAttach', call, unit)
                    local idx = nil
                    for i, u in pairs(call.units) do
                        if u.id == unit.id then
                            idx = i
                        end
                    end
                    if idx == nil then
                        table.insert(call.units, unit)
                        SetCallCache(body.data.callId, { dispatch_type = "CALL_EDIT", dispatch = call })
                    end
                else
                    debugLog("Attach failure, unknown call or unit")
                end
            end
        else
            debugLog("No idents in attachment?!")
        end
        return true
    end,
    EVENT_DISPATCH_UNIT_DETACH = function(body)
        local call = GetCallCache()[body.data.callId]
        if body.data.ident ~= nil then
            local unit = GetUnitCache()[body.data.ident]
            if call and unit then
                TriggerEvent('SonoranCAD::pushevents:UnitDetach', call, unit)
                local idx = nil
                debugLog("detach call "..json.encode(call))
                if call.units ~= nil then
                    for i, u in pairs(call.units) do
                        if u.id == unit.id then
                            idx = i
                        end
                    end
                    if idx ~= nil then
                        table.remove(call.units, idx)
                        SetCallCache(body.data.callId, {dispatch_type = "CALL_EDIT", dispatch = call })
                    end
                end
            else
                debugLog("Detach failure, unknown call or unit")
            end
        elseif body.data.idents ~= nil then
            for i=1, #body.data.idents do
                local unit = GetUnitCache()[body.data.idents[i]]
                if call and unit then
                    TriggerEvent('SonoranCAD::pushevents:UnitDetach', call, unit)
                    local idx = nil
                    for i, u in pairs(call.units) do
                        if u.id == unit.id then
                            idx = i
                        end
                    end
                    if idx ~= nil then
                        table.remove(call.units, idx)
                        SetCallCache(body.data.callId, { dispatch_type = "CALL_EDIT", dispatch = call })
                    end
                else
                    debugLog("Detach failure, unknown call or unit")
                end
            end
        end
        return true
    end,
    GET_LOGS = function(body)
        TriggerEvent('SonoranCAD::pushevents:SendSupportLogs', body.logKey)
        return true
    end,
    EVENT_911 = function(body)
        SetEmergencyCache(body.data.call.callId, body.data.call)
        TriggerEvent('SonoranCAD::pushevents:IncomingCadCall', body.data.call, body.data.call.metaData, body.data.apiIds)
        return true
    end,
    EVENT_REMOVE_911 = function(body)
        SetEmergencyCache(body.data.callId, nil)
        TriggerEvent('SonoranCAD::pushevents:CadCallRemoved', body.data.callId)
        return true
    end,
    EVENT_STREETSIGN_UPDATED = function(body)
        TriggerEvent('SonoranCAD::pushevents:SmartSignUpdate', body.data.signData)
        return true
    end,
    EVENT_RECORD_ADD = function(body)
        TriggerEvent('SonoranCAD::pushevents:RecordAdded', body.data.record)
        return true
    end,
    EVENT_RECORD_EDIT = function(body)
        TriggerEvent('SonoranCAD::pushevents:RecordEdited', body.data.record)
        return true
    end,
    EVENT_RECORD_REMOVE = function(body)
        TriggerEvent('SonoranCAD::pushevents:RecordRemoved', body.data.record)
        return true
    end
}

SetHttpHandler(function(req, res)
    local path = req.path
    local method = req.method

    if method == 'POST' and path == '/info' then
        req.setDataHandler(function(body)
            if not body then
                res.send(json.encode({["error"] = "bad request"}))
                return
            end
            local data = json.decode(body)
            if not data then
                res.send(json.encode({["error"] = "bad request"}))
            elseif Config.critError then
                res.send(json.encode({["error"] = "critical config error"}))
            elseif string.upper(data.password) ~= string.upper(Config.apiKey) then
                res.send(json.encode({["error"] = "bad request"}))
            else
                local pluginsFormatted = {}
                for name, plugin in pairs(Config.plugins) do
                    table.insert(pluginsFormatted, name..": "..json.encode(plugin))
                end
                res.send(json.encode({
                    ["status"] = "ok", 
                    ["cadInfo"] = string.gsub(dumpInfo(), "\n", "<br />"), 
                    ["config"] = table.concat(pluginsFormatted, "<br /><br/>"),
                    ["console"] = string.gsub(GetConsoleBuffer(), "\n", "<br />")
                }))
            end
        end)
    elseif method == "POST" and path == '/console' then
        req.setDataHandler(function(body)
            if not body then
                res.send(json.encode({["error"] = "bad request"}))
                return
            end
            local data = json.decode(body)
            if not data then
                res.send(json.encode({["error"] = "bad request"}))
            elseif Config.critError then
                res.send(json.encode({["error"] = "critical config error"}))
            elseif string.upper(data.password) ~= string.upper(Config.apiKey) then
                res.send(json.encode({["error"] = "bad request"}))
            else
                local s = string.gmatch(data.command, "%S+")()
                if s ~= "sonoran" then
                    res.send(json.encode({["error"] = "not allowed"}))
                    return
                end
                ExecuteCommand(data.command)
                res.send(json.encode({
                    ["status"] = "ok", 
                    ["output"] = string.gsub(GetConsoleBuffer(), "\n", "<br />")
                }))
            end
        end)
    elseif method == "POST" and path == '/event' then
        req.setDataHandler(function(data)
            if not data then
                res.send(json.encode({["error"] = "bad request"}))
                return
            end
            local body = json.decode(data)
            if not body then
                res.send(json.encode({["error"] = "bad request"}))
                debugLog("Invalid event: "..tostring(body))
                return
            end
            if body.key and body.key:upper() == Config.apiKey:upper() then
                debugLog(("EVENT: %s - %s"):format(body.type, json.encode(body)))
                if PushEventHandler[body.type:upper()] then
                    CreateThread(function()
                        body.res = res 
                        local success, result = PushEventHandler[body.type:upper()](body)
                        if success then
                            res.send("ok")
                        else
                            res.send(result);
                        end
                    end)
                else
                    res.send(json.encode({["error"] = "Invalid API request type."}))
                end
            end
        end)
    else
        if path == '/' then
            local html = LoadResourceFile(GetCurrentResourceName(), '/core/html/index.html')
            res.send(html)
        else
            res.send("If you're seeing this, sonorancad is loaded.")
        end
    end
end)

AddEventHandler("SonoranCAD::pushevents:shim", function(chunk)
    local body = json.decode(chunk)
    if not body then
        debugLog("Invalid event: "..tostring(chunk))
        return
    end
    if body.key and body.key:upper() == Config.apiKey:upper() then
        if PushEventHandler[body.type:upper()] then
            CreateThread(function()
                body.res = res 
                local success, result = PushEventHandler[body.type:upper()](body)
            end)
        end
    end
end)