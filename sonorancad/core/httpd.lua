local function getConfig()
    local config = LoadResourceFile(GetCurrentResourceName(), "config.json")
    return config
end

local UnitCache = {}
local CallCache = {}

function GetUnitCache() return UnitCache end
function GetCallCache() return CallCache end

local function findUnitIdByIdentifier(identIds)
    for k, v in pairs(UnitCache) do
        if v.data ~= nil and v.data.apidIds ~= nil then
            for x=1, #v.data.apiIds do
                if has_value(identIds, v.data.apiIds[x]) then
                    return x
                end
            end
        end
    end
    return nil
end

-- Global function wrapper
function GetUnitByIdentifier(identifiers) return findUnitIdByIdentifier(identifiers) end

-- Event Handlers
local PushEventHandler = {
    EVENT_UNIT_STATUS = function(body)
        if (not body.data.identIds) then
            return false, "missing identIds"
        end
        local i = findUnitIdByIdentifier(body.data.identIds)
        if i then
            UnitCache[i].status = body.data.status
            TriggerEvent('SonoranCAD::pushevents:UnitUpdate', UnitCache[i], status)
        else
            debugLog(("EVENT_UNIT_STATUS: Unknown unit, idents: %s - status: %s"):format(json.encode(body.data.identIds), status))
        end
        return true
    end,
    EVENT_UNIT_LOGIN = function(body)
        if (not body.data.id) then
            return false, "missing ID"
        end
        UnitCache[body.data.id] = body.data.unit
        UnitCache[body.data.id].isDispatch = body.data.isDispatch
        TriggerEvent('SonoranCAD::pushevents:UnitLogin', UnitCache[body.data.id])
        return true
    end,
    EVENT_UNIT_LOGOUT = function(body)
        if (not body.data.identId) then
            return false, "missing identId"
        end
        TriggerEvent('SonoranCAD::pushevents:UnitLogout', body.data.identId)
    end,

    --[[
        RegisterServerEvent("SonoranCAD::pushevents:DispatchEvent")
    AddEventHandler("SonoranCAD::pushevents:DispatchEvent", function(data)
        local dispatchType = data.dispatch_type
        local dispatchData = data.dispatch
        local metaData = data.dispatch.metaData
]]
    EVENT_DISPATCH_NEW = function(body)
        CallCache[body.data.dispatch.callId] = { dispatch_type = "CALL_NEW", dispatch = body.data }
        TriggerEvent('SonoranCAD::pushevents:DispatchEvent', CallCache[body.data.dispatch.callId])
    end,
    EVENT_DISPATCH_EDIT = function(body)
        CallCache[body.data.dispatch.callId] = { dispatch_type = "CALL_EDIT", dispatch = body.data }
        TriggerEvent('SonoranCAD::pushevents:DispatchEvent', CallCache[body.data.dispatch.callId])
    end,
    EVENT_DISPATCH_CLOSE = function(body)
        if CallCache[body.data.callId] ~= nil then
            local d = { dispatch_type = "CALL_CLOSE", dispatch = CallCache[body.data.callId] }
            TriggerEvent('SonoranCAD::pushevents:DispatchEvent', CallCache[body.data.dispatch.callId])
        else
            debugLog(("Unknown call close (call ID %s), current cache: %s"):format(body.data.callId, json.encode(CallCache)))
        end
    end,
    EVENT_DISPATCH_NOTE = function(body)
        TriggerEvent('SonoranCAD::pushevents:DispatchNote', body.data)
    end,
    EVENT_UNIT_ATTACH = function(body)
        -- fetch the call and unit data
        local call = CallCache[body.data.callId]
        if body.data.ident ~= nil then
            local unit = UnitCache[body.data.ident]
            if call and unit then
                TriggerEvent('SonoranCAD::pushevents:UnitAttach', call, unit)
            else
                debugLog("Attach failure, unknown call or unit")
            end
        elseif body.data.idents ~= nil then
            for i=1, #body.data.idents do
                local unit = UnitCache[body.data.idents[i]]
                if call and unit then
                    TriggerEvent('SonoranCAD::pushevents:UnitAttach', call, unit)
                else
                    debugLog("Attach failure, unknown call or unit")
                end
            end
        else
            debugLog("No idents in attachment?!")
        end
    end,
    EVENT_UNIT_DETACH = function(body)
        local call = CallCache[body.data.callId]
        if body.data.ident ~= nil then
            local unit = UnitCache[body.data.ident]
            if call and unit then
                TriggerEvent('SonoranCAD::pushevents:UnitDetach', call, unit)
            else
                debugLog("Detach failure, unknown call or unit")
            end
        end
    end,
    GET_LOGS = function(body)
        TriggerEvent('SonoranCAD::pushevents:SendSupportLogs', body.logKey)
    end,
    EVENT_911 = function(body)
        TriggerEvent('SonoranCAD::pushevents:IncomingCadCall', body.data.call, body.data.apiIds, body.data.metaData)
    end,
    EVENT_REMOVE_911 = function(body)
        TriggerEvent('SonoranCAD::pushevents:CadCallRemoved', body.data.callId)
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