--[[
    SonoranCAD FiveM Integration

    Plugin Loader

    Provides logic for checking loaded plugins after startup
]]

CreateThread(function()
    while Config.apiVersion == -1 do Wait(10) end
    if Config.critError then logError("ERROR_ABORT") end
    for k, v in pairs(Config.plugins) do
        if Config.critError then
            Config.plugins[k].enabled = false
            Config.plugins[k].disableReason = "Startup aborted"
            goto skip
        end
        if Config.plugins[k].requiresPlugins ~= nil then
            for _, plugin in pairs(Config.plugins[k].requiresPlugins) do
                local isCritical = plugin.critical
                if isCritical then
                    logError("PLUGIN_DEPENDENCY_ERROR", getErrorText(
                                 "PLUGIN_DEPENDENCY_ERROR"):format(k,
                                                                   plugin.name))
                    Config.plugins[k].enabled = false
                    Config.plugins[k].disableReason =
                        ("Missing dependency %s"):format(plugin.name)
                elseif plugin.name ~= "esxsupport" then
                    warnLog(
                        ("[plugin loader] Plugin %s requires %s, but it is not installed. Some features may not work properly."):format(
                            k, plugin.name))
                end
            end
        end
    end
    ::skip::
    local pluginList = {}
    local loadedPlugins = {}
    local disabledPlugins = {}
    local disableFormatted = {}
    for name, v in pairs(Config.plugins) do
        table.insert(pluginList, name)
        if v.enabled then
            table.insert(loadedPlugins, name)
        else
            if v.disableReason == nil then
                v.disableReason = "disabled in config"
            end
            disabledPlugins[name] = v.disableReason
        end
    end
    infoLog(("Available Plugins: %s"):format(table.concat(pluginList, ", ")))
    infoLog(("Loaded Plugins: %s"):format(table.concat(loadedPlugins, ", ")))
    for name, reason in pairs(disabledPlugins) do
        table.insert(disableFormatted, ("%s (%s)"):format(name, reason))
    end
    if #disableFormatted > 0 then
        warnLog(("Disabled Plugins: %s"):format(
                    table.concat(disableFormatted, ", ")))
    end
end)