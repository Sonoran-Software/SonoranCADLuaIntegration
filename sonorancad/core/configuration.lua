Config = {
    communityID = nil,
    apiKey = nil,
    apiUrl = nil,
    postTime = nil,
    serverId = nil,
    serverType = nil,
    primaryIdentifier = nil,
    apiSendEnabled = nil,
    debugMode = nil,
    updateBranch = nil,
    plugins = {}
}

local conf = LoadResourceFile(GetCurrentResourceName(), "config.json")
if not conf or conf == nil then
    errorLog("Failed to load core configuration. Ensure config.json is present.")
    assert(false, "Invalid configuration file.")
    return
end
for k, v in pairs(json.decode(conf)) do
    Config[k] = v
end

if Config.updateBranch == nil then
    Config.updateBranch = "master"
end

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
        if Config.plugins[pluginName].enabled == nil then
            Config.plugins[pluginName].enabled = true
        end
        return Config.plugins[pluginName]
    else
        if pluginName == "yourpluginname" then
            return { enabled = false }
        end
        if not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/config_%s.lua"):format(pluginName, pluginName, pluginName)) and not LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/config_%s.lua"):format(pluginName, pluginName))  then
            warnLog(("Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-plugins/integration-plugins/plugin-installation for steps to properly install."):format(pluginName))
        end
        Config.plugins[pluginName] = { enabled = false }
        return { enabled = false }
    end
end

RegisterServerEvent("SonoranCAD::core::getConfig")
AddEventHandler("SonoranCAD::core::getConfig", function()
    local config = json.encode({
        communityID = Config.communityID,
        apiKey = Config.apiKey,
        postTime = Config.postTime,
        serverType = Config.serverType,
        apiSendEnabled = Config.apiSendEnabled
    })
    TriggerEvent("SonoranCAD::core:configData", config)
end)

RegisterNetEvent("SonoranCAD::core:sendClientConfig")
AddEventHandler("SonoranCAD::core:sendClientConfig", function()
    local config = {
        communityID = Config.communityID,
        postTime = Config.postTime,
        serverId = Config.serverId,
        serverType = Config.serverType,
        primaryIdentifier = Config.primaryIdentifier,
        apiSendEnabled = Config.apiSendEnabled,
        debugMode = Config.debugMode,
        statusLabels = Config.statusLabels
    }
    TriggerClientEvent("SonoranCAD::core:recvClientConfig", source, config)
end)

CreateThread(function()
    Wait(2000) -- wait for server to settle
    local detectedMapPort = GetConvar("socket_port", "30121")
    local detectedPushPort = GetConvar("SonoranListenPort", "3232")
    local isMapRunning = (isPluginLoaded("livemap") and GetResourceState("sonoran_livemap") == "started")
    local isPushEventsRunning = isPluginLoaded("pushevents")
    local serverId = Config.serverId

    print(("r: %s %s %s %s"):format(detectedMapPort, detectedPushPort, isMapRunning, isPushEventsRunning))

    if isMapRunning or isPushEventsRunning then
        performApiRequest({}, "GET_SERVERS", function(response)
            local info = json.decode(response)
            for k, v in pairs(info.servers) do
                print(("Check %s = %s"):format(v.id, serverId))
                if tostring(v.id) == tostring(serverId) then
                    ServerInfo = v
                    break
                end
            end
            if ServerInfo == nil then
                errorLog(("Could not find valid server information for server ID %s. Ensure you have configured your server in the CAD before using the map or push events."):format(serverId))
                return
            end
            if ServerInfo.mapPort ~= tostring(detectedMapPort) and isMapRunning then
                errorLog(("CONFIGURATION PROBLEM: Map port on the server (%s) does not match your CAD configuration (%s) for server ID (%s). Please ensure they match."):format(detectedMapPort, ServerInfo.mapPort, serverId))
            end
            if ServerInfo.listenerPort ~= tostring(detectedPushPort) and isPushEventsRunning then
                errorLog(("CONFIGURATION PROBLEM: Listener port on the server (%s) does not match your CAD configuration (%s) for server ID (%s). Please ensure they match."):format(detectedPushPort, ServerInfo.listenerPort, serverId))
            end

        end)
    end
end)