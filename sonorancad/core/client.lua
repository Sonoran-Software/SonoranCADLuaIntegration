Config = {
    plugins = {}
}
Plugins = {}

Config.RegisterPluginConfig = function(pluginName, configs)
    Config.plugins[pluginName] = {}
    for k, v in pairs(configs) do
        Config.plugins[pluginName][k] = v
    end 
    table.insert(Plugins, pluginName)
end
Config.GetPluginConfig = function(pluginName) 
    if Config.plugins[pluginName] ~= nil then
        if Config.critError then
            Config.plugins[pluginName].enabled = false
            Config.plugins[pluginName].disableReason = "startup aborted"
        elseif Config.plugins[pluginName].enabled == nil then
            Config.plugins[pluginName].enabled = true
        elseif Config.plugins[pluginName].enabled == false then
            Config.plugins[pluginName].disableReason = "Disabled"
        end
        return Config.plugins[pluginName]
    else
        if pluginName == "yourpluginname" then
            return { enabled = false, disableReason = "Template plugin" }
        end
        if not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/config_%s.lua"):format(pluginName, pluginName, pluginName)) and not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/config_%s.lua"):format(pluginName, pluginName))  then
            warnLog(("Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-plugins/integration-plugins/plugin-installation for steps to properly install."):format(pluginName))
        end
        Config.plugins[pluginName] = { enabled = false, disableReason = "Missing configuration file" }
        return { enabled = false, disableReason = "Missing configuration file" }
    end
end

Config.LoadPlugin = function(pluginName, cb)
    while Config.apiVersion == -1 do
        Wait(1)
    end
    if Config.plugins[pluginName] ~= nil then
        if Config.critError then
            Config.plugins[pluginName].enabled = false
            Config.plugins[pluginName].disableReason = "startup aborted"
        elseif Config.plugins[pluginName].enabled == nil then
            Config.plugins[pluginName].enabled = true
        elseif Config.plugins[pluginName].enabled == false then
            Config.plugins[pluginName].disableReason = "Disabled"
        end
        return cb(Config.plugins[pluginName])
    else
        if pluginName == "yourpluginname" then
            return cb({ enabled = false, disableReason = "Template plugin" })
        end
        if not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/config_%s.lua"):format(pluginName, pluginName, pluginName)) and not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/config_%s.lua"):format(pluginName, pluginName))  then
            warnLog(("Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-plugins/integration-plugins/plugin-installation for steps to properly install."):format(pluginName))
        end
        Config.plugins[pluginName] = { enabled = false, disableReason = "Missing configuration file" }
        return cb({ enabled = false, disableReason = "Missing configuration file" })
    end
end

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(1)
    end
    TriggerServerEvent("SonoranCAD::core:sendClientConfig")
end)

RegisterNetEvent("SonoranCAD::core:recvClientConfig")
AddEventHandler("SonoranCAD::core:recvClientConfig", function(config)
    for k, v in pairs(config) do
        Config[k] = v
    end
    Config.inited = true
    debugLog("Configuration received")
end)

CreateThread(function()
    while not Config.inited do
        Wait(10)
    end
    if Config.devHiddenSwitch then
        debugLog("Spawned discord thread")
        SetDiscordAppId(867548404724531210)
        SetDiscordRichPresenceAsset("icon")
        SetDiscordRichPresenceAssetSmall("icon")
        while true do
            SetRichPresence("Developing SonoranCAD!")
            Wait(5000)
            SetRichPresence("sonorancad.com")
            Wait(5000)
        end
    end
end)

local inited = false
AddEventHandler("playerSpawned", function()
    TriggerServerEvent("SonoranCAD::core:PlayerReady")
    inited = true
end)

RegisterNetEvent("SonoranCAD::core:debugModeToggle")
AddEventHandler("SonoranCAD::core:debugModeToggle", function(toggle)
    Config.debugMode = toggle
end)

RegisterNetEvent("SonoranCAD::core:AddPlayer")
RegisterNetEvent("SonoranCAD::core:RemovePlayer")