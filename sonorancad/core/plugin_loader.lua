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

        -- Plugin updater system
        local f = LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/version_%s.json"):format(k, k, k))
        if f ~= nil then
            local version = json.decode(f)
            if version.check_url ~= "" then
                PerformHttpRequest(version.check_url, function(code, data, headers)
                    if code == 200 then
                        local remote = json.decode(data)
                        if remote.version ~= version.version then
                            infoLog(("Plugin Updater: %s has an available update! %s -> %s - Download at: %s"):format(k, version.version, remote.version, remote.download_url.."releases/"))
                        end
                        if remote.configVersion ~= nil then
                            local myversion = version.configVersion ~= nil and version.configVersion or "0.0"
                            if remote.configVersion ~= version.configVersion then
                                infoLog(("Plugin Updater: %s has a new configuration version. You should look at the template configuration file (CHANGEMEconfig_%s.lua) and update your configuration."):format(k, k))
                            end
                        end
                    else
                        errorLog(("Failed to check plugin updates for %s: %s %s"):format(k, code, data))
                    end
                end, "GET")
            end
        else
            debugLog("Got an empty version file for "..k)
        end
    end
    local pluginList = {}
    for name, v in pairs(Config.plugins) do
        table.insert(pluginList, name)
    end
    infoLog(("Loaded plugins: %s"):format(table.concat(pluginList, ", ")))
end)