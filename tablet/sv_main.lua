CallCache = {}
EmergencyCache = {}
UnitCache = {}

CreateThread(function()
    Wait(0)
    if CONFIG == nil then
        warnLog("Config file wasn't found for tablet resource. Assuming defaults.")
        SetConvarReplicated("sonorantablet_keyPrevious", 'LEFT')
        SetConvarReplicated("sonorantablet_keyAttach", 'K')
        SetConvarReplicated("sonorantablet_keyDetail", 'L')
        SetConvarReplicated("sonorantablet_keyNext", 'RIGHT')
        SetConvarReplicated("sonorantablet_cadUrl", 'https://sonorancad.com/')
    else
        for k, v in pairs(CONFIG) do
            if GetConvar("sonorantablet_"..k, "NONE") == "NONE" then
                SetConvarReplicated("sonorantablet_"..k, tostring(v))
            end
        end
    end
    while true do
        Wait(1000)
        CallCache = exports["sonorancad"]:GetCallCache()
        UnitCache = exports["sonorancad"]:GetUnitCache()
        for k, v in pairs(CallCache) do
            v.dispatch.units = {}
            if v.dispatch.idents then
                for ka, va in pairs(v.dispatch.idents) do
                    local unit
                    local unitId = exports["sonorancad"]:GetUnitById(va)
                    table.insert(v.dispatch.units, UnitCache[unitId]);
                end
            end
        end
        TriggerClientEvent("SonoranCAD::mini:CallSync", -1, CallCache, EmergencyCache)
    end
end)

AddEventHandler("SonoranCAD::pushevents:DispatchNote", function(data)
    TriggerClientEvent("SonoranCAD::mini:NewNote", -1, data)
end)

RegisterServerEvent("SonoranCAD::mini:OpenMini")
AddEventHandler("SonoranCAD::mini:OpenMini", function ()
    local ident = exports["sonorancad"]:GetUnitByPlayerId(source)
    if ident == nil then TriggerClientEvent("SonoranCAD::mini:OpenMini:Return", source, false) end
    if ident.data == nil then TriggerClientEvent("SonoranCAD::mini:OpenMini:Return", source, false) end
    if ident.data.apiIds[1] == nil then TriggerClientEvent("SonoranCAD::mini:OpenMini:Return", source, false) end
    TriggerClientEvent("SonoranCAD::mini:OpenMini:Return", source, true, ident.id)
end)

exports["sonorancad"]:registerApiType("ATTACH_UNIT", "emergency")
RegisterServerEvent("SonoranCAD::mini:AttachToCall")
AddEventHandler("SonoranCAD::mini:AttachToCall", function(callId)
    local ident = exports["sonorancad"]:GetUnitByPlayerId(source)
    if ident ~= nil then
        local data = {callId = callId, units = {ident.data.apiIds[1]}, serverId = 1}
        exports["sonorancad"]:performApiRequest({data}, "ATTACH_UNIT", function(res)
            --print("Attach OK: " .. tostring(res))
        end)
    else
        --print("Unable to attach... if api id is set properly, try relogging into cad.")
    end
end)

exports["sonorancad"]:registerApiType("DETACH_UNIT", "emergency")
RegisterServerEvent("SonoranCAD::mini:DetachFromCall")
AddEventHandler("SonoranCAD::mini:DetachFromCall", function(callId)
    local ident = exports["sonorancad"]:GetUnitByPlayerId(source)
    if ident ~= nil then
        local data = {callId = callId, units = {ident.data.apiIds[1]}, serverId = 1}
        exports["sonorancad"]:performApiRequest({data}, "DETACH_UNIT", function(res)
            --print("Detach OK: " .. tostring(res))
        end)
    else
        --print("Unable to detach... if api id is set properly, try relogging into cad.")
    end
end)