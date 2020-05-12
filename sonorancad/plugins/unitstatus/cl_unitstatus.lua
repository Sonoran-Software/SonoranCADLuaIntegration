--[[
    Sonaran CAD Plugins

    Plugin Name: unitstatus
    Creator: SonoranCAD
    Description: Allows updating unit status

    Put all client-side logic in this file.
]]

local pluginConfig = Config.plugins["unitstatus"]


if pluginConfig.setStatusCommand ~= "" then
    RegisterCommand(pluginConfig.setStatusCommand, function(source, args, rawCommand)
        if #args == 1 then
            if pluginConfig.statusCodes[args[1]] ~= nil then
                TriggerServerEvent("SonoranCAD::unitstatus:UpdateStatus", args[1])
            end
        else
            print("Invalid arguments.")
        end
    end, false)
    TriggerEvent('chat:addSuggestion', pluginConfig.setStatusCommand, 'Sets your status in the CAD', {
        { name="Status to set", help="UNAVAILABLE/AVAILABLE/ON_SCENE/ENROUTE/BUSY" }
    })
end

RegisterNetEvent("SonoranCAD::unitstatus:StatusUpdate")
AddEventHandler("SonoranCAD::unitstatus:StatusUpdate", function(apiId, status, success)
    if success then
        print("Successfully changed status.")
    else
        print("Failed to change status.")
    end
end)