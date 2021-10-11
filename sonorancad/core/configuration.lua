Config = {
    communityID = nil,
    apiKey = nil,
    apiUrl = nil,
    postTime = nil,
    serverId = nil,
    primaryIdentifier = nil,
    apiSendEnabled = nil,
    debugMode = nil,
    updateBranch = nil,
    enableCanary = false,
    latestVersion = "",
    apiVersion = -1,
    plugins = {},
}

Config.RegisterPluginConfig = function(pluginName, configs)
    Config.plugins[pluginName] = {}
    for k, v in pairs(configs) do
        Config.plugins[pluginName][k] = v
        --debugLog(("plugin %s set %s = %s"):format(pluginName, k, v))
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
        end
        return Config.plugins[pluginName]
    else
        if pluginName == "yourpluginname" then
            return { enabled = false, disableReason = "Template plugin" }
        end
        if pluginName == "apicheck" then
            return { enabled = false, disableReason = "deprecated plugin" }
        end
        if not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/config_%s.lua"):format(pluginName, pluginName, pluginName)) and not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/config_%s.lua"):format(pluginName, pluginName))  then
            warnLog(("Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-plugins/integration-plugins/plugin-installation for steps to properly install."):format(pluginName))
            Config.plugins[pluginName] = { enabled = false, disableReason = "Missing configuration file" }
            return { enabled = false, disableReason = "Missing configuration file" }
        end
        Config.plugins[pluginName] = { enabled = false, disableReason = "disabled" }
        return { enabled = false, disableReason = "disabled" }
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
        end
        return cb(Config.plugins[pluginName])
    else
        if pluginName == "yourpluginname" then
            return cb({ enabled = false, disableReason = "Template plugin" })
        end
        if not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/config_%s.lua"):format(pluginName, pluginName, pluginName)) and not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/config_%s.lua"):format(pluginName, pluginName))  then
            warnLog(("Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-plugins/integration-plugins/plugin-installation for steps to properly install."):format(pluginName))
            Config.plugins[pluginName] = { enabled = false, disableReason = "Missing configuration file" }
            return cb({ enabled = false, disableReason = "Missing configuration file" })
        end
        Config.plugins[pluginName] = { enabled = false, disableReason = "disabled" }
        return cb({ enabled = false, disableReason = "disabled" })
    end
end

local conf = LoadResourceFile(GetCurrentResourceName(), "config.json")
if conf == nil then
    errorLog("Failed to load core configuration. Ensure config.json is present.")
    Config.critError = true
    Config.apiSendEnabled = false
    return
end
local parsedConfig = json.decode(conf)
if parsedConfig == nil then
    errorLog("Failed to parse your config file. Make sure it is valid JSON.")
    Config.critError = true
    Config.apiSendEnabled = false
    return
end
for k, v in pairs(json.decode(conf)) do
    local cvar = GetConvar("sonoran_"..k, "NONE")
    local val = nil
    if cvar ~= "NONE" and cvar ~= "statusLabels" then
        debugLog(("Configuration: Overriding config option %s with convar. New value: %s"):format(k, cvar))
        if cvar == "true" then
            cvar = true
        elseif cvar == "false" then
            cvar = false
        end
        Config[k] = cvar
        val = cvar
    else
        Config[k] = v
        val = v
    end
    if k ~= "apiKey" then
        SetConvar("sonoran_"..k, tostring(val))
    end
end

if Config.updateBranch == nil then
    Config.updateBranch = "master"
end

RegisterNetEvent("SonoranCAD::core:sendClientConfig")
AddEventHandler("SonoranCAD::core:sendClientConfig", function()
    local config = {
        communityID = Config.communityID,
        postTime = Config.postTime,
        serverId = Config.serverId,
        primaryIdentifier = Config.primaryIdentifier,
        apiSendEnabled = Config.apiSendEnabled,
        debugMode = Config.debugMode,
        devHiddenSwitch = Config.devHiddenSwitch,
        statusLabels = Config.statusLabels
    }
    TriggerClientEvent("SonoranCAD::core:recvClientConfig", source, config)
end)

CreateThread(function()
    Wait(2000) -- wait for server to settle
    if Config.critError then
        return
    end
    local detectedMapPort = GetConvar("socket_port", "30121")
    local isMapRunning = (isPluginLoaded("livemap") and GetResourceState("sonoran_livemap") == "started")
    local serverId = Config.serverId
    performApiRequest({}, "GET_SERVERS", function(response)
        local info = json.decode(response)
        for k, v in pairs(info.servers) do
            if tostring(v.id) == tostring(serverId) then
                ServerInfo = v
                break
            end
        end
        if ServerInfo == nil then
            errorLog(("Could not find valid server information for server ID %s. Ensure you have configured your server in the CAD before using the map or push events."):format(serverId))
            return
        end
        if ServerInfo.listenerPort ~= GetConvar("netPort", "0") then
            errorLog(("CONFIGURATION PROBLEM: Your current game server port (%s) does not match your CAD configuration (%s). Please ensure they match."):format(GetConvar("netPort", "0"), ServerInfo.listenerPort))
        end
        if ServerInfo.mapPort ~= tostring(detectedMapPort) and isMapRunning then
            errorLog(("CONFIGURATION PROBLEM: Map port on the server (%s) does not match your CAD configuration (%s) for server ID (%s). Please ensure they match."):format(detectedMapPort, ServerInfo.mapPort, serverId))
        end
        PerformHttpRequest("https://api.ipify.org?format=json", function(errorCode, resultData, resultHeaders)
            local r = json.decode(resultData)
            if r ~= nil and r.ip ~= nil then
                debugLog(("IP DETECT - IP: %s - Detected: %s - Outbound set: %s - Outbound IP: %s"):format(ServerInfo.mapIp, r.ip, ServerInfo.differingOutbound, ServerInfo.outboundIp))
                if ServerInfo.mapIp ~= r.ip then
                    if ServerInfo.differingOutbound and ServerInfo.outboundIp == r.ip then
                        infoLog("Detected proper differing outbound IP configuration.")
                    else
                        if ServerInfo.differingOutbound then
                            errorLog(("CONFIGURATION PROBLEM: Detected outbound IP (%s), but (%s) is configured in the CAD. They must match!"):format(r.ip, ServerInfo.outboundIp))
                        else
                            errorLog(("CONFIGURATION PROBLEM: Detected IP (%s), but (%s) is configured in the CAD. They must match!"):format(r.ip, ServerInfo.mapIp))
                        end
                    end
                end
            end
        end, "GET", nil, nil)
    end)

    if isPluginLoaded("pushevents") then
        warnLog("Since 2.5.0, SonoranCAD now uses your game port for push events. While the old method will work, this is deprecated. Please change your game port settings under Admin -> Advanced -> In-Game Integration to reflect this server's game port.")
        warnLog("After changing this information, please remove or disable the pushevents plugin to remove this message.")
    end
end)