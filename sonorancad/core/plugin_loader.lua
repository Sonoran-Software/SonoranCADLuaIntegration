--[[
    SonoranCAD FiveM Integration

    Plugin Loader

    Provides logic for checking loaded plugins after startup
]]

local function LoadVersionFile(pluginName)
    local f = LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/version_%s.json"):format(pluginName, pluginName, pluginName))
    if f then
        return f
    else
        f = LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/version_%s.json"):format(pluginName, pluginName)) 
        if f then
            return f
        else
            return nil
        end
    end
end

CreateThread(function()
    Wait(1)
    for k, v in pairs(Config.plugins) do
        if Config.plugins[k].requiredPlugins ~= nil then
            for _, v in pairs(Config.plugins[k].requiredPlugins) do
                if Plugins[v] == nil then
                    errorLog(("Plugin %s requires %s, which is not loaded!"):format(k, v))
                end
            end
        end
        -- Plugin updater system
        local f = LoadVersionFile(k)
        if f ~= nil then
            local version = json.decode(f)
            debugLog(("Loaded plugin %s (%s)"):format(k, version.version))
            Config.plugins[k].version = version.version
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
            if version.minCoreVersion ~= nil then
                local coreVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
                _, _, v1, v2, v3 = string.find( version.minCoreVersion, "(%d+)%.(%d+)%.(%d+)" )
                _, _, r1, r2, r3 = string.find( coreVersion, "(%d+)%.(%d+)%.(%d+)" )
                v1 = v1 and tonumber(v1) or 0
                v2 = v2 and tonumber(v2) or 0
                v3 = v3 and tonumber(v3) or 0
                r1 = tonumber(r1)
                r2 = tonumber(r2)
                r3 = tonumber(r3)
                debugLog(("versions: %s.%s.%s - %s.%s.%s"):format(r1, r2, r3, v1, v2, v3))
                if v1 > r1 or v2 > r2 or v3 > r3 then
                    errorLog(("PLUGIN ERROR: Plugin %s requires Core Version %s, but you have %s. Please update SonoranCAD to use this plugin. Force disabled."):format(k, version.minCoreVersion, coreVersion))
                    Config.plugins[k].enabled = false
                end
            end
        else
            debugLog("Got an empty version file for "..k)
        end
    end
    local pluginList = {}
    local loadedPlugins = {}
    local disabledPlugins = {}
    for name, v in pairs(Config.plugins) do
        table.insert(pluginList, name)
        if v.enabled then
            table.insert(loadedPlugins, name)
        else
            table.insert(disabledPlugins, name)
        end
    end
    infoLog(("Available Plugins: %s"):format(table.concat(pluginList, ", ")))
    infoLog(("Loaded Plugins: %s"):format(table.concat(loadedPlugins, ", ")))
    if #disabledPlugins > 0 then
        warnLog(("Disabled Plugins: %s"):format(table.concat(disabledPlugins, ", ")))
    end
end)