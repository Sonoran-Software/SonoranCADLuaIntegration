--[[
    Sonaran CAD Plugins

    Plugin Name: kick
    Creator: Taylor McGaw
    Description: Kicks user from the cad upon exiting the server
]]

local pluginConfig = Config.GetPluginConfig("kick")

if pluginConfig.enabled then

    local PendingKicks = {}
    registerApiType("KICK_UNIT", "emergency")
    AddEventHandler("playerDropped", function()
        local source = source
        local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
        if not identifier then
            debugLog("kick: no API ID, skip")
            return
        end
        table.insert(PendingKicks, identifier)
    end)

    CreateThread(function()
        while true do
            if #PendingKicks > 0 then
                local kicks = {}
                while true do
                    local pendingKick = table.remove(PendingKicks)
                    if pendingKick ~= nil then
                        table.insert(kicks, {["apiId"] = pendingKick, ["reason"] = "You have exited the server", ["serverId"] = Config.serverId})
                    else
                        break
                    end
                end
                performApiRequest(kicks, 'KICK_UNIT', function() end)
            end
            Wait(10000)
        end
    end)
end