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

RegisterCommand("sonoran", function(source, args, rawCommand)
    if source ~= 0 then
        print("Console only command")
        return
    end
    if not args[1] then
        print("Missing command. Try \"sonoran help\" for help.")
        return
    end
    if args[1] == "debugmode" then
        Config.debugMode = not Config.debugMode
        infoLog(("Debug mode toggled to %s"):format(Config.debugMode))
    elseif args[1] == "info" then
        local version = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
        local pluginList, loadedPlugins, disabledPlugins = GetPluginLists()
        local pluginVersions = {}
        for k, v in pairs(pluginList) do
            if Config.plugins[v] then
                table.insert(pluginVersions, ("%s [%s]"):format(v, Config.plugins[v].version))
            end
        end
        print(([[
SonoranCAD
    Version: %s
Available Plugins
    %s
Loaded Plugins
    %s
Disabled Plugins
    %s
        ]]):format(version, table.concat(pluginVersions, ", "), table.concat(loadedPlugins, ", "), table.concat(disabledPlugins, ", ")))
    elseif args[1] == "support" then
        return
    elseif args[1] == "verify" then
        return
    elseif args[1] == "plugin" and args[2] then
        if Config.plugins[args[2]] then
            local pluginDetail = {}
            for k, v in pairs(Config.plugins[args[2]]) do
                table.insert(pluginDetail, ("%s = %s"):format(k, v))
            end
            print(([[
Plugin: %s
Version: %s
Configuration:
     %s
            ]]):format(args[2], Config.plugins[args[2]].version, table.concat(pluginDetail, "\n     ")))
        else
            errorLog("Invalid plugin")
        end
    elseif args[1] == "update" then
        return
    else
        print("Missing command. Try \"sonoran help\" for help.")
    end
end, true)

function GetPluginLists()
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
    return pluginList, loadedPlugins, disabledPlugins
end