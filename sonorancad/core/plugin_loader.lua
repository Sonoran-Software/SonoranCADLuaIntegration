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
            warnLog(("Failed to load version file from either %s or %s. Check to see if the file exists."):format(("plugins/%s/%s/version_%s.json"):format(pluginName, pluginName, pluginName), ("plugins/%s/version_%s.json"):format(pluginName, pluginName)))
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

local function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

local function downloadPlugin(name, url)
    local zipname = "latest"
    if Config.enableCanary then
        zipname = "canary"
    end
    local releaseUrl = ("%s/archive/%s.zip"):format(url, zipname)
    PerformHttpRequest(releaseUrl, function(code, data, headers)
        if code == 200 then
            exports[GetCurrentResourceName()]:CreateFolderIfNotExisting(GetResourcePath(GetCurrentResourceName()).."/pluginupdates/")
            local savePath = GetResourcePath(GetCurrentResourceName()).."/pluginupdates/"..name..".zip"
            local f = assert(io.open(savePath, 'wb'))
            f:write(data)
            f:close()
            local unzipPath = GetResourcePath(GetCurrentResourceName()).."/plugins/"
            if exists(("%s/%s/%s/"):format(unzipPath, name, name)) then
                -- nested, edit unzip path
                debugLog("Nested plugin detected, adjusting path")
                unzipPath = ("%s/%s/"):format(unzipPath, name)
            end
            debugLog("Unzipping to: "..unzipPath)
            exports[GetCurrentResourceName()]:UnzipFolder(savePath, name, unzipPath)
            os.remove(savePath)
            infoLog(("Plugin %s successfully downloaded."):format(name))
            PluginsWereUpdated = true
        else
            if not Config.enableCanary then
                errorLog(("Failed to download from %s: %s %s"):format(realUrl, code, data))
            end
        end
    end, "GET")
end

function CheckForPluginUpdate(name, forceUpdate)
    local plugin = Config.plugins[name]
    if plugin == nil then
        errorLog(("Plugin %s not found."):format(name))
        return
    elseif plugin.check_url == nil or plugin.check_url == "" then
        debugLog(("Plugin %s does not have check_url set. Is it configured correctly?"):format(name))
        return
    end
    if Config.enableCanary then
        plugin.check_url = plugin.check_url:gsub("main", "canary"):gsub("master", "canary")
    end
    if forceUpdate then
        infoLog(("Checking %s for updates..."):format(name))
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
                    if remote.download_url ~= nil and remote.download_url ~= "" then
                        if Config.allowAutoUpdate or forceUpdate then
                            infoLog(("Attempting to automatically update %s..."):format(name))
                            downloadPlugin(name, remote.download_url)
                            PluginsWereUpdated = true
                        else
                            warnLog("Automatic updates are disabled. Please update this plugin ASAP.")
                        end
                    else
                        warnLog(("Plugin %s does not have download_url set. Is it configured correctly?"):format(name))
                    end
                else
                    if forceUpdate then
                        infoLog(("No updates for %s (%s >= %s)"):format(name, plugin.version, remote.version))
                    end
                end
                if remote.configVersion ~= nil and plugin.configVersion ~= nil then
                    if remote.configVersion ~= plugin.configVersion and not Config.debugMode then
                        errorLog(("Plugin Updater: %s has a new configuration version. You should look at the template configuration file (CHANGEMEconfig_%s.lua) and update your configuration before using this plugin."):format(name, name))
                        Config.plugins[name].enabled = false
                        Config.plugins[name].disableReason = "outdated config file"
                    end
                end
            end
            
        else
            if not Config.enableCanary then
                errorLog(("Failed to check plugin updates for %s: %s %s"):format(name, code, data))
            end
        end
    end, "GET")
end

CreateThread(function()
    while Config.apiVersion == -1 do
        Wait(10)
    end
    if Config.critError then
        errorLog("Aborted startup due to above errors.")
    end
    for k, v in pairs(Config.plugins) do
        if Config.critError then
            Config.plugins[k].enabled = false
            Config.plugins[k].disableReason = "Startup aborted"
            goto skip
        end
        
        local vfile = LoadVersionFile(k)
        if vfile == nil then
            goto skip
        end
        local versionFile = json.decode(vfile)
        if versionFile.pluginDepends == nil and Config.plugins[k].requiresPlugins ~= nil then
            -- legacy
            debugLog(("Plugin %s using legacy dependency detection. This should be corrected in a future version."):format(k))
            if Config.plugins[k].requiresPlugins ~= nil then
                for _, v in pairs(Config.plugins[k].requiresPlugins) do
                    debugLog(("Checking %s dependency %s"):format(k, v))
                    if Config.plugins[v] == nil or not Config.plugins[v].enabled then
                        errorLog(("Plugin %s requires %s, which is not loaded! Skipping."):format(k, v))
                        Config.plugins[k].enabled = false
                        Config.plugins[k].disableReason = ("Missing dependency %s"):format(v)
                        goto skip
                    end
                end
            end
        elseif versionFile.pluginDepends ~= nil then
            for _, plugin in pairs(versionFile.pluginDepends) do
                local requiredVersion = string.gsub(plugin.version, "%.","")
                local isCritical = plugin.critical
                -- get the depend plugin information
                local vFile = LoadVersionFile(plugin.name)
                if vFile == nil then
                    if isCritical then
                        errorLog(("PLUGIN ERROR: Plugin %s requires the %s plugin, but it is not installed."):format(k, plugin.name))
                        Config.plugins[k].enabled = false
                        Config.plugins[k].disableReason = ("Missing dependency %s"):format(plugin.name)
                    elseif plugin.name ~= "esxsupport" then
                        warnLog(("[plugin loader] Plugin %s requires %s, but it is not installed. Some features may not work properly."):format(k, plugin.name))
                    end
                else
                    local check = json.decode(vFile)
                    -- check if its version >= required
                    local checkVersion = string.gsub(check.version, "%.","")
                    if (checkVersion < requiredVersion) then
                        if isCritical then
                            errorLog(("PLUGIN ERROR: Plugin %s requires %s at version %s or higher, but only %s was found. Use the command \"sonoran pluginupdate\" to check for updates."):format(k, plugin.name, plugin.version, check.version))
                            Config.plugins[k].enabled = false
                            Config.plugins[k].disableReason = ("Wrong version for dependency %s (%s)"):format(plugin.name, plugin.version)
                        else
                            warnLog(("INCOMPATIBILITY WARNING: Plugin %s requires %s at version %s or higher, but only %s was found. Some features may not work! Use the command \"sonoran pluginupdate\" to check for updates."):format(k, plugin.name, plugin.version, check.version))
                        end
                    else
                        debugLog(("Plugin %s checked plugin %s version (%s >= %s)"):format(k, plugin.name, check.version, plugin.version))
                    end
                end
            end
        end
        -- Plugin updater system
        if k ~= nil then
            local version = versionFile
            debugLog(("Loaded plugin %s (%s)"):format(k, version.version))
            Config.plugins[k].version = version.version
            Config.plugins[k].check_url = version.check_url
            Config.plugins[k].download_url = version.download_url
            if version.configVersion ~= nil and Config.plugins[k].configVersion ~= nil and Config.plugins[k].configVersion ~= version.configVersion then
                errorLog(("Plugin Updater: %s has a new configuration version (%s ~= %s). You should look at the template configuration file (CHANGEMEconfig_%s.lua) and update your configuration before using this plugin."):format(k, Config.plugins[k].configVersion, version.configVersion, k))
                Config.plugins[k].enabled = false
                Config.plugins[k].disableReason = "outdated config file"
            end
            CheckForPluginUpdate(k)
            if version.minCoreVersion ~= nil then
                local coreVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
                local minVersion = string.gsub(version.minCoreVersion, "%.","")
                local coreVersion = string.gsub(coreVersion, "%.", "")
                if minVersion > coreVersion then
                    errorLog(("PLUGIN ERROR: Plugin %s requires Core Version %s, but you have %s. Please update SonoranCAD to use this plugin. Force disabled."):format(k, version.minCoreVersion, coreVersion))
                    Config.plugins[k].enabled = false
                    Config.plugins[k].disableReason = "Outdated core version"
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
        warnLog(("Disabled Plugins: %s"):format(table.concat(disableFormatted, ", ")))
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