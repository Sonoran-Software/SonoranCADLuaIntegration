--[[
    SonoranCAD FiveM Integration

    Plugin Loader

    Provides logic for checking loaded plugins after startup
]]

local PluginsWereUpdated = false

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

local function doRestart()
    CreateThread(function()
        if not Config.allowUpdateWithPlayers and GetNumPlayerIndices() > 0 then
            infoLog("Delaying auto-update until server is empty.")
            return
        end
        warnLog("Auto-restarting...")
        local f = assert(io.open(GetResourcePath("sonoran_updatehelper").."/run.lock", "w+"))
        f:write("plugin")
        f:close()
        Wait(5000)
        ExecuteCommand("ensure sonoran_updatehelper")
    end)
end

local function downloadPlugin(name, url)
    local releaseUrl = ("%s/archive/latest.zip"):format(url)
    PerformHttpRequest(releaseUrl, function(code, data, headers)
        if code == 200 then
            local savePath = GetResourcePath(GetCurrentResourceName()).."/pluginupdates/"..name..".zip"
            local f = assert(io.open(savePath, 'wb'))
            f:write(data)
            f:close()
            local unzipPath = GetResourcePath(GetCurrentResourceName()).."/plugins/"..name.."/"
            debugLog("Unzipping to: "..unzipPath)
            exports[GetCurrentResourceName()]:UnzipFolder(savePath, name, unzipPath)
            os.remove(savePath)
            infoLog(("Plugin %s successfully downloaded."):format(name))
            PluginsWereUpdated = true
        else
            errorLog(("Failed to download from %s: %s %s"):format(realUrl, code, data))
        end
    end, "GET")
end

function CheckForPluginUpdate(name, checkUrl)
    local plugin = Config.plugins[name]
    if plugin == nil then
        errorLog(("Plugin %s not found."):format(name))
        return
    elseif plugin.check_url == nil then
        errorLog("no check url")
        return
    end
    PerformHttpRequestS(plugin.check_url, function(code, data, headers)
        if code == 200 then
            local remote = json.decode(data)
            if remote == nil then
                warnLog(("Failed to get a valid response for %s. Skipping."):format(k))
                debugLog(("Raw output for %s: %s"):format(k, data))
            else
                Config.plugins[name].latestVersion = remote.version
                Config.plugins[name].download_url = remote.download_url
                local latestVersion = string.gsub(remote.version, "%.","")
                local localVersion = string.gsub(plugin.version, "%.", "")
                if localVersion < latestVersion then
                    warnLog(("Plugin Updater: %s has an available update! %s -> %s"):format(name, plugin.version, remote.version))
                    if remote.download_url ~= nil then
                        if Config.allowAutoUpdate then
                            infoLog(("Attempting to automatically update %s..."):format(name))
                            downloadPlugin(name, remote.download_url)
                            PluginsWereUpdated = true
                        else
                            warnLog("Automatic updates are disabled. Please update this plugin ASAP.")
                        end
                    end
                end
                if remote.configVersion ~= nil then
                    local myversion = plugin.configVersion ~= nil and plugin.configVersion or "0.0"
                    if remote.configVersion ~= plugin.configVersion then
                        infoLog(("Plugin Updater: %s has a new configuration version. You should look at the template configuration file (CHANGEMEconfig_%s.lua) and update your configuration."):format(name, name))
                    end
                end
            end
            
        else
            errorLog(("Failed to check plugin updates for %s: %s %s"):format(k, code, data))
        end
    end, "GET")
end

CreateThread(function()
    Wait(1)
    for k, v in pairs(Config.plugins) do
        if Config.plugins[k].requiresPlugins ~= nil then
            for _, v in pairs(Config.plugins[k].requiresPlugins) do
                debugLog(("Checking %s dependency %s"):format(k, v))
                if Config.plugins[v] == nil or not Config.plugins[v].enabled then
                    errorLog(("Plugin %s requires %s, which is not loaded! Skipping."):format(k, v))
                    Config.plugins[k].enabled = false
                    goto skip
                end
            end
        end
        -- Plugin updater system
        local f = LoadVersionFile(k)
        if f ~= nil then
            local version = json.decode(f)
            debugLog(("Loaded plugin %s (%s)"):format(k, version.version))
            Config.plugins[k].version = version.version
            Config.plugins[k].check_url = version.check_url
            Config.plugins[k].download_url = version.download_url
            Config.plugins[k].configVersion = version.configVersion or "1.0"
            CheckForPluginUpdate(k)
            if version.minCoreVersion ~= nil then
                local coreVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
                local minVersion = string.gsub(version.minCoreVersion, "%.","")
                local coreVersion = string.gsub(coreVersion, "%.", "")
                if minVersion > coreVersion then
                    errorLog(("PLUGIN ERROR: Plugin %s requires Core Version %s, but you have %s. Please update SonoranCAD to use this plugin. Force disabled."):format(k, version.minCoreVersion, coreVersion))
                    Config.plugins[k].enabled = false
                end
            end
        else
            debugLog("Got an empty version file for "..k)
        end
        ::skip::
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
    if PluginsWereUpdated then
        doRestart()
    end
end)

CreateThread(function()
    while true do
        Wait(10000)
        if PluginsWereUpdated then
            doRestart()
        end
        Wait(60000*10)
        for k, v in pairs(Config.plugins) do
            CheckForPluginUpdate(k)
        end
    end
end)