local UnitCache = {}
local CallCache = {}
local PlayerUnitMapping = {}

local function findUnitById(identIds)
    for k, v in pairs(UnitCache) do
        if type(identIds) == "number" then
            if identIds == v.id then
                return k
            end
        elseif has_value(identIds, v.id) then
            return k
        end
    end
    return nil
end
local function GetSourceByApiId(apiIds)
    if apiIds == nil then return nil end
    for x=1, #apiIds do
        for i=0, GetNumPlayerIndices()-1 do
            local player = GetPlayerFromIndex(i)
            if player then
                local identifiers = GetIdentifiers(player)
                for type, id in pairs(identifiers) do
                    if id == apiIds[x] then
                        return player
                    end
                end
            end
        end
    end
    return nil
end 

function GetUnitCache() return UnitCache end
function GetCallCache() return CallCache end
function SetUnitCache(k, v) 
    local key = findUnitById(k)
    if key ~= nil and UnitCache[key] ~= nil then
        UnitCache[key] = v
    else
        table.insert(UnitCache, v)
    end
end
function SetCallCache(k, v) CallCache[k] = v end
function GetUnitByPlayerId(player) return PlayerUnitMapping[player] end


-- Global function wrapper
function GetUnitById(ids) return findUnitById(ids) end

exports('GetUnitByPlayerId', GetUnitByPlayerId)
exports('GetUnitCache', GetUnitCache)
exports('GetCallCache', GetCallCache)
exports('GetUnitById', GetUnitById)


AddEventHandler("playerDropped", function()
    local id = GetUnitByPlayerId(source)
    local unit = findUnitById(id)
    if unit then
        TriggerEvent("SonoranCAD::core:RemovePlayer", source, UnitCache[unit])
        UnitCache[unit] = nil
    end
end)

AddEventHandler("SonoranCAD::pushevents:UnitLogin", function(unit)
    local playerId = GetSourceByApiId(unit.data.apiIds)
    if playerId then
        PlayerUnitMapping[playerId] = unit.id
        TriggerEvent("SonoranCAD::core:AddPlayer", playerId, unit)
    end
end)

AddEventHandler("SonoranCAD::pushevents:UnitLogout", function(id)
    local key = findUnitById(id)
    if key then
        PlayerUnitMapping[key] = nil
    end
    SetUnitCache(id, nil)
end)


registerApiType("GET_ACTIVE_UNITS", "emergency")
Citizen.CreateThread(function()
    Wait(500)
    if not Config.apiSendEnabled or Config.noUnitTimer or ApiVersion < 3 then
        debugLog("Disabling active units routine")
        return
    end
    while true do
        local OldUnits = {}
        local NewUnits = {}
        for k, v in pairs(UnitCache) do
            OldUnits[k] = v
        end
        if GetNumPlayerIndices() > 0 then
            local payload = { serverId = Config.serverId}
            performApiRequest({payload}, "GET_ACTIVE_UNITS", function(runits)
                local allUnits = json.decode(runits)
                if allUnits ~= nil then
                    for k, v in pairs(allUnits) do
                        local playerId = GetSourceByApiId(v.data.apiIds)
                        if playerId then
                            PlayerUnitMapping[playerId] = v.id
                            table.insert(NewUnits, v)
                            TriggerEvent("SonoranCAD::core:AddPlayer", playerId, v)
                        end
                    end
                end
                for k, v in pairs(OldUnits) do
                    debugLog(("Removing player %s, not on units list"):format(k))
                    TriggerEvent("SonoranCAD::core:RemovePlayer", k, v)
                end
            end)
        end
        UnitCache = {}
        for k, v in pairs(NewUnits) do
            table.insert(UnitCache, v)
        end
        Citizen.Wait(60000)
    end
end)