--[[
    SonoranCAD FiveM Integration

    Plugin Loader

    Provides logic for checking loaded plugins after startup
]]

CreateThread(function()
    Wait(1)
    for k, v in pairs(Config.plugins) do
        debugLog(("Checking plugin %s..."):format(k))
        if Config.plugins[k].requiredPlugins ~= nil then
            for _, v in pairs(Config.plugins[k].requiredPlugins) do
                if Plugins[v] == nil then
                    warningLog(("Plugin %s requires %s, which is not loaded!"):format(k, v))
                end
            end
        end
        debugLog(("Plugin %s loaded OK"):format(k))
    end
end)