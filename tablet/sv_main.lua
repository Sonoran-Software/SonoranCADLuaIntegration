CallCache = {}
EmergencyCache = {}

CreateThread(function()
    while GetResourceState("sonorancad") ~= "started" do
        print("Waiting for sonorancad resource to start... (current state: "..GetResourceState("sonorancad")..")")
        Wait(5000)
    end

    local function debounce(fn, time)
        local i = 0
        return function()
            i = i + 1
            local iCopy = i
            Citizen.CreateThread(function()
                Wait(time)
                -- invoke if 'i' hasn't been incremented since this thread was created
                if i == iCopy then fn() end
            end)
        end
    end
    -- safely remove keys of an object based on a predicate
    local function removeKeyAt(obj, predicate)
        local kToRemove = {}
        for k, v in pairs(obj) do
            if predicate(k, v) then
                table.insert(kToRemove, k)
            end
        end
        for _, k in ipairs(kToRemove) do
            obj[k] = nil
        end
        return obj
    end

    local function miniCadCallSync()
        local callCache = exports['sonorancad']:GetCallCache()
        local unitCache = exports['sonorancad']:GetUnitCache()
        removeKeyAt(callCache, function(k, v)
            -- only include active calls
            if v.dispatch.status ~= 1 then return true end

            -- add unit info to the call (idk if this is really needed)
            v.dispatch.units = {}
            if v.dispatch.idents then
                for _, va in pairs(v.dispatch.idents) do
                    local unitId = exports['sonorancad']:GetUnitById(va)
                    table.insert(v.dispatch.units, unitCache[unitId])
                end
            end
            return false
        end)
        CallCache = callCache

        -- the cache already removes stale 911 calls, no need to use removeKeyAt
        EmergencyCache = exports["sonorancad"]:GetEmergencyCache()

        -- TODO: only send to active units
        TriggerClientEvent("SonoranCAD::mini:CallSync", -1, CallCache, EmergencyCache)
    end
    local miniCadCallSyncDebounced = debounce(miniCadCallSync, 1000)
    miniCadCallSyncDebounced() -- call immediately for sync

    -- watch for calls and emergencies
    -- NOTE: debounce because these can come through in quick succession
    AddEventHandler('SonoranCAD::pushevents:CallCacheUpdated', miniCadCallSyncDebounced)
    AddEventHandler('SonoranCAD::pushevents:EmergencyCacheUpdated', miniCadCallSyncDebounced)

    RegisterNetEvent("SonoranCAD::mini:CallSync_S")
    AddEventHandler("SonoranCAD::mini:CallSync_S", function()
        TriggerClientEvent("SonoranCAD::mini:CallSync", source, CallCache, EmergencyCache)
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
        TriggerClientEvent("SonoranCAD::mini:CallSync", source, CallCache, EmergencyCache)
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

