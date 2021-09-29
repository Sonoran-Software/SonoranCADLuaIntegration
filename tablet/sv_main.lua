CallCache = {}
EmergencyCache = {}
UnitCache = {}

CreateThread(function()
    while GetResourceState("sonorancad") ~= "started" do
        print("Waiting for sonorancad resource to start... (current state: "..GetResourceState("sonorancad")..")")
        Wait(5000)
    end

    CreateThread(function()
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
        if ident == nil then TriggerClientEvent("SonoranCAD::mini:OpenMini:Return", source, false) return end
        if ident.data == nil then TriggerClientEvent("SonoranCAD::mini:OpenMini:Return", source, false) return end
        if ident.data.apiIds[1] == nil then TriggerClientEvent("SonoranCAD::mini:OpenMini:Return", source, false) return end
        TriggerClientEvent("SonoranCAD::mini:OpenMini:Return", source, true, ident.id)
    end)
    
    RegisterServerEvent("SonoranCAD::mini:AttachToCall")
    AddEventHandler("SonoranCAD::mini:AttachToCall", function(callId)
        local ident = exports["sonorancad"]:GetUnitByPlayerId(source)
        if ident ~= nil then
            local data = {callId = callId, units = {ident.data.apiIds[1]}, serverId = GetConvar("sonoran_serverId", 1)}
            exports["sonorancad"]:performApiRequest({data}, "ATTACH_UNIT", function(res)
                --print("Attach OK: " .. tostring(res))
            end)
        else
            --print("Unable to attach... if api id is set properly, try relogging into cad.")
        end
    end)

    RegisterServerEvent("SonoranCAD::mini:DetachFromCall")
    AddEventHandler("SonoranCAD::mini:DetachFromCall", function(callId)
        local ident = exports["sonorancad"]:GetUnitByPlayerId(source)
        if ident ~= nil then
            local data = {callId = callId, units = {ident.data.apiIds[1]}, serverId = GetConvar("sonoran_serverId", 1)}
            exports["sonorancad"]:performApiRequest({data}, "DETACH_UNIT", function(res)
                --print("Detach OK: " .. tostring(res))
            end)
        else
            --print("Unable to detach... if api id is set properly, try relogging into cad.")
        end
    end)
end)

