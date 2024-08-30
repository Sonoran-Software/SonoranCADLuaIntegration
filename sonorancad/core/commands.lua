--[[
    SonoranCAD FiveM Integration

    Commands Module

    Provides /sonoran command for console control
]]

--[[ /sonoran
    debugmode - old caddebug toggle
    info - dump version info, configuration
    support - dump useful data for support staff
    verify - run hash checks to confirm all files are untampered
    plugin <name> - show info about a plugin (config)
    update - attempt to auto-update
]]

registerApiType("UPLOAD_LOGS", "support")

function dumpInfo()
    local version = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    local pluginList, loadedPlugins, disabledPlugins = GetPluginLists()
    local pluginVersions = {}
    local cadVariables = { ["netPort"] = GetConvar("netPort", "Unknown")}
    local variableList = ""
    for k, v in pairs(cadVariables) do
        variableList = ("%s%s = %s\n"):format(variableList, k, v)
    end
    for k, v in pairs(pluginList) do
        if Config.plugins[v] then
            table.insert(pluginVersions, ("%s [%s/%s]"):format(v, Config.plugins[v].version, Config.plugins[v].latestVersion))
        end
    end
    local coreConfig = {}
    for k, v in pairs(Config) do
        if (k == "plugins") then goto continue end
        if type(v) == "function" then goto continue end
        if type(v) == "table" then
            table.insert(coreConfig, ("%s = %s"):format(k, json.encode(v)))
            goto continue
        end
        if type(v) == "thread" then goto continue end
        table.insert(coreConfig, ("%s = %s"):format(k, v))
        coreConfig[k] = v
        ::continue::
    end
    return ([[
SonoranCAD
Version: %s - Latest: %s
FXS Version: %s
Available Plugins
%s
Loaded Plugins
%s
Disabled Plugins
%s
Relevant Variables
%s
Core Configuration
%s
    ]]):format(version, Config.latestVersion, getServerVersion(), table.concat(pluginVersions, ", "), table.concat(loadedPlugins, ", "), table.concat(disabledPlugins, ", "), variableList, table.concat(coreConfig, "\n"))
end

function dumpPlugin(name)
    local pluginDetail = {}
    if not Config.plugins[name] then
        print("Bad plugin: "..name)
        return nil
    end
    for k, v in pairs(Config.plugins[name]) do
        table.insert(pluginDetail, ("%s = %s"):format(k, v))
    end
    return ([[
Plugin: %s
Version: %s
Configuration:
    %s
    ]]):format(name, Config.plugins[name].version, table.concat(pluginDetail, "\n     "))
end

local function sendSupportLogs(key)
    infoLog("Please wait, gathering required data...")
    local cadOutput = {}
    cadOutput.key = tonumber(key)
    if cadOutput.key == nil then
        errorLog("Invalid support key.")
        return
    end
    local plugins = {}
    for name, config in pairs(Config.plugins) do
        pluginData = {}
        pluginData.name = name
        pluginData.version = config.version
        pluginData.config = config
        table.insert(plugins, pluginData)
    end
    cadOutput.plugins = plugins
    cadOutput.logs = ([[
SonoranCAD Support Output
---------------------------------------
Configuration Information
---
%s

---------------------------------------
Console Buffer
------
%s
---------------------------------------
Last 50 Debug Messages
----------------------
%s
    ]]):format(dumpInfo(), GetConsoleBuffer(), table.concat(getDebugBuffer(), "\n"))
    Config.debugMode = false
    performApiRequest({cadOutput}, "UPLOAD_LOGS", function(data)
        if data == "LOGS UPDATED" then
            infoLog("Support logs have been successfully uploaded. Debug mode was disabled during the upload.")
        else
            errorLog(("Failed to upload support logs: %s"):format(data))
        end
    end)
end
RegisterCommand("sonoran", function(source, args, rawCommand)
    if source ~= 0 then
        print("Console only command")
        return
    end
    if not args[1] then
        print("Missing command. Try \"sonoran help\" for help.")
        return
    end
    if args[1] == "help" then
        print([[
SonoranCAD Help
    debugmode - Toggles debugging mode
    info - dump version info, configuration
    support - dump useful data for support staff
    errors - display all error/warning messages since last startup
    plugin <name> - show info about a plugin (config)
    update - Run core updater
    pluginupdate - Run plugin updater
    viewcaches - View the current unit and call cache, for troubleshooting
    getclientlog <playerId> - Get a log buffer from a given client
    dumpconsole - Dumps current console buffer to file
]])
    elseif args[1] == "debugmode" then
        Config.debugMode = not Config.debugMode
        local convarString = ""
        if Config.debugMode then
            convarString = "true"
        else
            convarString = "false"
        end
        SetConvar("sonoran_debugMode", convarString)
        infoLog(("Debug mode toggled to %s"):format(convarString))
        TriggerClientEvent("SonoranCAD::core:debugModeToggle", -1, Config.debugMode)
    elseif args[1] == "info" then
        print(dumpInfo())
    elseif args[1] == "support" and args[2] ~= nil then
        sendSupportLogs(args[2])
    elseif args[1] == "plugin" and args[2] then
        if Config.plugins[args[2]] then
            print(dumpPlugin(args[2]))
        else
            errorLog("Invalid plugin")
        end
    elseif args[1] == "update" then --update - attempt to auto-update
        infoLog("Checking for core update...")
        RunAutoUpdater(true)
    elseif args[1] == "dumpconsole" then
        local savePath = GetResourcePath(GetCurrentResourceName()).."/buffer.log"
        local f = assert(io.open(savePath, 'wb'))
        f:write(GetConsoleBuffer())
        f:close()
        infoLog("Wrote buffer to "..savePath)
    elseif args[1] == "pluginupdate" then
        infoLog("Scanning for plugin updates...")
        for k, v in pairs(Config.plugins) do
            CheckForPluginUpdate(k, true)
        end
    elseif args[1] == "viewcaches" then
        local units = GetUnitCache()
        local calls = GetCallCache()
        print(("Units: %s\r\nCalls: %s"):format(json.encode(units), json.encode(calls)))
        print("Done")
    elseif args[1] == "getclientlog" then
        if args[2] then
            if GetPlayerName(args[2]) ~= nil then
                TriggerClientEvent("SonoranCAD::core:RequestLogBuffer", args[2])
                infoLog("Requested log buffer. Please wait...")
            else
                errorLog("Invalid player ID")
            end
        else
            errorLog("Invalid argument.")
        end
    elseif args[1] == "errors" then
        print("----ERROR/WARNING BUFFER START----")
        local buf = getErrorBuffer()
        for i=1, #buf do
            print(buf[i])
        end
        print("----ERROR/WARNING BUFFER END----")
    else
        print("Missing command. Try \"sonoran help\" for help.")
    end
end, true)

function GetPluginLists()
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
    for name, reason in pairs(disabledPlugins) do
        table.insert(disableFormatted, ("%s (%s)"):format(name, reason))
    end
    return pluginList, loadedPlugins, disableFormatted
end

-- Support Push Event

AddEventHandler("SonoranCAD::pushevents:SendSupportLogs", function(key)
    infoLog("Support has requested logs to be uploaded. Collecting now...")
    sendSupportLogs(key)
end)

RegisterNetEvent("SonoranCAD::core:LogBuffer")
AddEventHandler("SonoranCAD::core:LogBuffer", function(buffer)
    infoLog(("Incoming log buffer from player %s"):format(source))
    for i=1, #buffer do
        print((": %s"):format(buffer[i]))
    end
    infoLog("End of buffer")
end)