--[[
    Sonaran CAD Plugins

    Plugin Name: unitstatus
    Creator: SonoranCAD
    Description: Allows updating unit status

    Put all client-side logic in this file.
]]

local pluginConfig = Config.GetPluginConfig("unitstatus")

if pluginConfig.enabled then

    local statuses = {}
    for k, v in pairs(pluginConfig.statusCodes) do
        statuses[v] = k
    end
    if pluginConfig.setStatusCommand ~= "" then
        RegisterCommand(pluginConfig.setStatusCommand, function(source, args, rawCommand)
            if #args == 1 then
                if pluginConfig.statusCodes[string.upper(args[1])] ~= nil or statuses[tonumber(args[1])] ~= nil then
                    TriggerServerEvent("SonoranCAD::unitstatus:UpdateStatus", args[1])
                else
                    TriggerEvent("chat:addMessage", {args = {"^0^5^*[SonoranCAD]^r ", "^7Status changed failed: unknown status."}})
                end
            else
                TriggerEvent("chat:addMessage", {args = {"^0^5^*[SonoranCAD]^r ", "^7Missing argument."}})
            end
        end)
        TriggerEvent('chat:addSuggestion', pluginConfig.setStatusCommand, 'Sets your status in the CAD', {
            { name="Status to set", help="UNAVAILABLE/AVAILABLE/ON_SCENE/ENROUTE/BUSY" }
        })
    end

    RegisterNetEvent("SonoranCAD::unitstatus:StatusUpdate")
    AddEventHandler("SonoranCAD::unitstatus:StatusUpdate", function(apiId, status, success)
        if success then
            TriggerEvent("chat:addMessage", {args = {"^0^5^*[SonoranCAD]^r ", ("^7Status successfully changed to ^5%s^7."):format(statuses[status])}})
        else
            TriggerEvent("chat:addMessage", {args = {"^0^5^*[SonoranCAD]^r ", "^7Status changed failed."}})
        end
    end)

end