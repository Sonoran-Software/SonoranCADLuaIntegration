CallCache = {}
EmergencyCache = {}
UnitCache = {}

CreateThread(function()
    while true do
        Wait(1000)
        CallCache = exports["sonorancad"]:GetCallCache();
        UnitCache = exports["sonorancad"]:GetUnitCache();
        --print(json.encode(UnitCache))
        -- Eventually Get Emergency Cache
        --EmergencyCache = exports["sonorancad"]:GetEmergencyCache();
        for k, v in pairs(CallCache) do
            v.dispatch.units = {}
            if v.dispatch.idents then 
                for ka, va in pairs(v.dispatch.idents) do
                    --print("idents: " .. va)
                    local unit
                    local unitId = exports["sonorancad"]:GetUnitById(va)
                    table.insert(v.dispatch.units, UnitCache[unitId]);
                    -- if (playerid) then unit = exports["sonorancad"]:GetUnitByPlayerId(playerid) end
                    --print("unit: " .. exports["sonorancad"]:GetUnitById(va))
                    -- 
                    --print(exports["sonorancad"]:GetUnitByPlayerId(va))
                end
            end
            -- print("Idents Call: ")
            -- print(json.encode(v.dispatch))
            -- print("idents")
            -- print(json.encode(v.dispatch.idents))
            -- print("units")
            -- print(json.encode(v.dispatch.units))
        end
        TriggerClientEvent("SonoranCAD::mini:CallSync", -1, CallCache, EmergencyCache)
    end
end)

AddEventHandler("SonoranCAD::pushevents:DispatchNote", function(data)
    TriggerClientEvent("SonoranCAD::mini:NewNote", -1, data)
end)

exports["sonorancad"]:registerApiType("ATTACH_UNIT", "emergency")
exports["sonorancad"]:registerApiType("DETACH_UNIT", "emergency")
RegisterServerEvent("SonoranCAD::mini:AttachToCall")
AddEventHandler("SonoranCAD::mini:AttachToCall", function(callId)
    print("cl_main -> sv_main: SonoranCAD::mini:AttachToCall")
    local ident = exports["sonorancad"]:GetUnitByPlayerId(source)
    local data = {callId = callId, units = {ident.data.apiIds[1]}, serverId = 1}
    exports["sonorancad"]:performApiRequest({data}, "DETACH_UNIT", function(res)
        print("Detach OK: " .. tostring(res))
    end)
    exports["sonorancad"]:performApiRequest({data}, "ATTACH_UNIT", function(res)
        print("Attach OK: " .. tostring(res))
    end)
end)