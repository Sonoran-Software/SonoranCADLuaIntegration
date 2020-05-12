--[[
    Sonaran CAD Plugins

    Plugin Name: unitstatus
    Creator: SonoranCAD
    Description: Allows updating unit status

    Put all server-side logic in this file.
]]

local pluginConfig = Config.plugins["unitstatus"]

registerApiType("UNIT_STATUS", "emergency")

function setUnitStatus(apiId, status, player)
    local statusNumber = nil
    if tonumber(status) ~= nil and status >= 0 and status <= 5 then
        statusNumber = tonumber(status)
    else
        statusNumber = tonumber(pluginConfig.statusCodes[status])
    end
    assert(statusNumber ~= nil, ("Status %s was not found in config"):format(status))
    local payload = {{["apiId"] = apiId, ["status"] = statusNumber}}
    performApiRequest(payload, "UNIT_STATUS", function(res, success)
        TriggerEvent("SonoranCAD::unitstatus:StatusUpdate", apiId, statusNumber, success)
        if player ~= nil then
            TriggerClientEvent("SonoranCAD::unitstatus:StatusUpdate", player, apiId, statusNumber, success)
        end
    end)
end

exports('cadSetUnitStatus', setUnitStatus)

RegisterNetEvent("SonoranCAD::unitstatus:UpdateStatus")
AddEventHandler("SonoranCAD::unitstatus:UpdateStatus", function(status)
    local ids = GetIdentifiers(source)
    local identifier = ids[Config.primaryIdentifier]
    setUnitStatus(identifier, status, source)
end)


