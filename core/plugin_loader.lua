--[[
    SonoranCAD FiveM Integration

    Plugin Loader

    Provides logic for checking loaded plugins after startup
]]

CreateThread(function()
    Wait(1)

    for k, v in pairs(Config.plugins) do
        debugPrint(("Checking plugin %s..."):format(k))
        for _, v in pairs(config.plugins[k].requiredPlugins) do
            if Plugins[v] == nil then
                warningLog(("Plugin %s requires %s, which is not loaded!"):format(k, v))
            end
        end
        debugPrint(("Plugin %s loaded OK"):format(k))
    end
end)