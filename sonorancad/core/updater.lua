local pendingRestart = false

local function doUnzip(path)
    local unzipPath = GetResourcePath(GetCurrentResourceName()).."/../../"
    exports[GetCurrentResourceName()]:UnzipFile(path, unzipPath)
end

AddEventHandler("unzipCoreCompleted", function(success, error)
    if success then
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
    else
        errorLog("Failed to download core update. "..tostring(error))
    end
end)

local function doUpdate(latest)
    -- best way to do this...
    local releaseUrl = ("https://github.com/Sonoran-Software/SonoranCADLuaIntegration/releases/download/v%s/sonorancad-%s.zip"):format(latest, latest)
    PerformHttpRequest(releaseUrl, function(code, data, headers)
        if code == 200 then
            local savePath = GetResourcePath(GetCurrentResourceName()).."/update.zip"
            local f = assert(io.open(savePath, 'wb'))
            f:write(data)
            f:close()
            infoLog("Saved file...")
            doUnzip(savePath)
        else
            warnLog(("Failed to download from %s: %s %s"):format(releaseUrl, code, data))
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
    local myVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

    PerformHttpRequestS(versionFile, function(code, data, headers)
        if code == 200 then
            local remote = json.decode(data)
            if remote == nil then
                warnLog(("Failed to get a valid response for %s. Skipping."):format(k))
                debugLog(("Raw output for %s: %s"):format(k, data))
            else
                Config.latestVersion = remote.resource
                local compare = compareVersions(remote.resource, myVersion)
                if compare.result then
                    if not Config.allowAutoUpdate then
                        print("^3|===========================================================================|")
                        print("^3|                        ^5SonoranCAD Update Available                        ^3|")
                        print("^3|                             ^8Current : " .. compare.version2 .. "                               ^3|")
                        print("^3|                             ^2Latest  : " .. compare.version1 .. "                               ^3|")
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
                        infoLog(("No updates available. Detected version %s, latest version is %s"):format(compare.version1, compare.version2))
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