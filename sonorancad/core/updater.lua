local pendingRestart = false

local function doUnzip(path)
    local unzipPath = GetResourcePath(GetCurrentResourceName()).."/../../"
    exports[GetCurrentResourceName()]:UnzipFile(path, unzipPath)
    infoLog("Unzipped to "..unzipPath)
    if not Config.allowUpdateWithPlayers and GetNumPlayerIndices() > 0 then
        pendingRestart = true
        infoLog("Delaying auto-update until server is empty.")
        return
    end
    warnLog("Auto-restarting...")
    local f = assert(io.open(GetResourcePath("sonoran_updatehelper").."/run.lock", "w+"))
    f:write("core")
    f:close()
    Wait(5000)
    ExecuteCommand("ensure sonoran_updatehelper")
end

local function doUpdate(latest)
    -- best way to do this...
    local releaseUrl = ("https://github.com/Sonoran-Software/SonoranCADLuaIntegration/releases/download/v%s/sonorancad-%s.zip"):format(latest, latest)
    if Config.enableCanary then
        releaseUrl = ("https://github.com/Sonoran-Software/SonoranCADLuaIntegration/releases/download/v%s-dev/sonorancad-%s-dev.zip"):format(latest, latest)
    end
    PerformHttpRequest(releaseUrl, function(code, data, headers)
        if code == 200 then
            local savePath = GetResourcePath(GetCurrentResourceName()).."/update.zip"
            local f = assert(io.open(savePath, 'wb'))
            f:write(data)
            f:close()
            infoLog("Saved file...")
            doUnzip(savePath)
        else
            if not Config.enableCanary then
                errorLog(("Failed to download from %s: %s %s"):format(realUrl, code, data))
            end
        end
    end, "GET")
    
end

function RunAutoUpdater(manualRun)
    if Config.updateBranch == nil then
        return
    end
    local f = LoadResourceFile(GetCurrentResourceName(), "/update.zip")
    if f ~= nil then
        -- remove the update file and stop the helper
        ExecuteCommand("stop sonoran_updatehelper")
        os.remove(GetResourcePath(GetCurrentResourceName()).."/update.zip")
        os.remove(GetResourcePath("sonoran_updatehelper").."/run.lock")
    end
    local versionFile = Config.autoUpdateUrl
    if versionFile == nil then
        versionFile = "https://raw.githubusercontent.com/Sonoran-Software/SonoranCADLuaIntegration/{branch}/sonorancad/version.json"
    end
    versionFile = string.gsub(versionFile, "{branch}", Config.updateBranch)
    if Config.enableCanary then
        versionFile = string.gsub(versionFile, "{branch}", "canary")
    end
    local myVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

    PerformHttpRequestS(versionFile, function(code, data, headers)
        if code == 200 then
            local remote = json.decode(data)
            if remote == nil then
                warnLog(("Failed to get a valid response for %s. Skipping."):format(k))
                debugLog(("Raw output for %s: %s"):format(k, data))
            else
                Config.latestVersion = remote.resource
                _, _, v1, v2, v3 = string.find( myVersion, "(%d+)%.(%d+)%.(%d+)" )
                _, _, r1, r2, r3 = string.find( remote.resource, "(%d+)%.(%d+)%.(%d+)" )
                if (string.find(myVersion, "-beta")) then
                    v3 = v3 - 0.5
                end
                debugLog(("my: %s remote: %s"):format(myVersion, remote.resource))
                local latestVersion = r3+(r2*100)+(r1*1000)
                local localVersion = v3+(v2*100)+(v1*1000)

                assert(localVersion ~= nil, "Failed to parse local version. "..tostring(localVersion))
                assert(latestVersion ~= nil, "Failed to parse remote version. "..tostring(latestVersion))

                if latestVersion > localVersion then
                    if not Config.allowAutoUpdate then
                        print("^3|===========================================================================|")
                        print("^3|                        ^5SonoranCAD Update Available                        ^3|")
                        print("^3|                             ^8Current : " .. localVersion .. "                               ^3|")
                        print("^3|                             ^2Latest  : " .. latestVersion .. "                               ^3|")
                        print("^3| Download at: ^4https://github.com/Sonoran-Software/SonoranCADLuaIntegration ^3|")
                        print("^3|===========================================================================|^7")
                        if Config.allowAutoUpdate == nil then
                            warnLog("You have not configured the automatic updater. Please set allowAutoUpdate in config.json to allow updates.")
                        end
                    else
                        infoLog("Running auto-update now...")
                        doUpdate(remote.resource)
                    end
                else
                    if manualRun then
                        infoLog(("No updates available. Detected version %s, latest version is %s"):format(localVersion, latestVersion))
                    end
                end
            end
        end
    end, "GET")
end


CreateThread(function()
    while true do
        if pendingRestart then
            if GetNumPlayerIndices() > 0 then
                warnLog("An update has been applied to SonoranCAD but requires a resource restart. Restart delayed until server is empty.")
            else
                infoLog("Server is empty, restarting resources...")
                local f = assert(io.open(GetResourcePath("sonoran_updatehelper").."/run.lock", "w+"))
                f:write("core")
                f:close()
                ExecuteCommand("ensure sonoran_updatehelper")
            end
        else
            RunAutoUpdater()
        end
        Wait(60000*60)
    end
end)