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
        TriggerEvent('SonoranCAD::pushevents:UnitUpdate', identIds, status)
        return true
    end,
    EVENT_UNIT_LOGIN = function(body)
        if (not body.data.id) then
            return false, "missing ID"
        end
        TriggerEvent('SonoranCAD::pushevents:UnitLogin', body.data.unit, body.data.isDispatch)
        return true
    end,
    EVENT_UNIT_LOGOUT = function(body)
        if (not body.data.identId) then
            return false, "missing identId"
        end
        TriggerEvent('SonoranCAD::pushevents:UnitLogout', body.data.identId)
    end,
    EVENT_DISPATCH_NEW = function(body)
        TriggerEvent('SonoranCAD::pushevents:DispatchAddEdit', body.data, true)
    end,
    EVENT_DISPATCH_EDIT = function(body)
        TriggerEvent('SonoranCAD::pushevents:DispatchAddEdit', body.data, false)
    end,
    EVENT_DISPATCH_CLOSE = function(body)
        TriggerEvent('SonoranCAD::pushevents:DispatchClosed', body.data.callId)
    end,
    EVENT_DISPATCH_NOTE = function(body)
        TriggerEvent('SonoranCAD::pushevents:DispatchNote', body.data)
    end,
    EVENT_UNIT_ATTACH = function(body)
        TriggerEvent('SonoranCAD::pushevents:UnitAttach', body.data)
    end,
    EVENT_UNIT_DETACH = function(body)
        TriggerEvent('SonoranCAD::pushevents:UnitDetach', body.data)
    end,
    GET_LOGS = function(body)
        TriggerEvent('SonoranCAD::pushevents:SendSupportLogs', body.logKey)
    end,
    EVENT_911 = function(body)
        TriggerEvent('SonoranCAD::pushevents:IncomingCadCall', body.data.call, body.data.apiIds, body.data.metaData)
    end,
    EVENT_REMOVE_911 = function(body)
        TriggerEvent('SonoranCAD::pushevents:', body.data.callId)
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
                res.send(json.encode({
                    ["status"] = "ok", 
                    ["cadInfo"] = string.gsub(dumpInfo(), "\n", "<br />"), 
                    ["config"] = string.gsub(getConfig(), "\r\n", "<br />")..string.gsub(json.encode(Config.plugins), "}", "} <br />"),
                    ["console"] = string.gsub(GetConsoleBuffer(), "\n", "<br />")
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
            res.send("hmm")
        end
    end
end)

-- Temporary shim
RegisterServerEvent("SonoranCAD::pushevents:shim")
AddEventHandler("SonoranCAD::pushevents:shim", function(data)
    debugLog("in shim with "..tostring(data))
    if not data then
        return
    end
    local body = json.decode(data)
    if not body then
        debugLog("Invalid event: "..tostring(body))
        return
    end
    --Config.apiKey:upper()
    if body.key and body.key:upper() == "REPLACEKEY" then
        if PushEventHandler[body.type:upper()] then
            PushEventHandler[body.type:upper()](body)
        end
    end
end)