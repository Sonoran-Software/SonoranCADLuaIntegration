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
    proxyUrl = ""
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
        if pluginName == "apicheck" or pluginName == "livemap" or pluginName == "smartsigns" then
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
    errorLog("CONFIG_ERROR: Unable to load configuration file. Ensure the file is named correctly (config.json). Check for extra extensions (like config.json.json).")
    Config.critError = true
    Config.apiSendEnabled = false
    return
end
local parsedConfig = json.decode(conf)
if parsedConfig == nil then
    errorLog("CONFIG_ERROR: Unable to parse configuration file. Ensure it is valid JSON.")
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

if GetConvar("web_baseUrl", "") ~= "" then
    Config.proxyUrl = ("https://%s/sonorancad/"):format(GetConvar("web_baseUrl", ""))
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
    local serverId = Config.serverId
    while Config.apiVersion == -1 do
        Wait(10)
    end
    if not Config.apiSendEnabled or Config.apiVersion < 3 then
        debugLog("Too low version or API disabled, ignore this")
        return
    end
    performApiRequest({}, "GET_SERVERS", function(response)
        local info = json.decode(response)
        for k, v in pairs(info.servers) do
            if tostring(v.id) == tostring(serverId) then
                ServerInfo = v
                break
            end
        end
        local needSetup = false
        local serverObj = {}
        if ServerInfo == nil then
            needSetup = true
            serverObj = {
                id = serverId,
                name = "Server "..serverId,
                description = "Server "..serverId,
                signal = "",
                listenerPort = GetConvar("netPort", "0"),
                mapIp = "",
                differingOutbound = false,
                outboundIp = "",
                enableMap = true,
                mapType = "NORMAL"
            }
        else
            serverObj = ServerInfo
        end
        if serverObj.name == "" then
            serverObj.name = "Server "..tostring(serverId)
        end
        if ServerInfo.listenerPort ~= GetConvar("netPort", "0") then
            infoLog(("Configuration information doesn't match, will attempt to auto-correct game port from %s to %s."):format(ServerInfo.listenerPort, GetConvar("netPort", "0")))
            serverObj.listenerPort = GetConvar("netPort", "0")
            needSetup = true
        end
        PerformHttpRequest("https://api.ipify.org?format=json", function(errorCode, resultData, resultHeaders)
            local r = json.decode(resultData)
            if r ~= nil and r.ip ~= nil then
                debugLog(("IP DETECT - IP: %s - Detected: %s - Outbound set: %s - Outbound IP: %s"):format(ServerInfo.mapIp, r.ip, ServerInfo.differingOutbound, ServerInfo.outboundIp))
                if serverObj.mapIp == "" or serverObj.mapIp == nil then
                    serverObj.mapIp = r.ip
                    needSetup = true
                end
                if ServerInfo.mapIp ~= r.ip then
                    if ServerInfo.differingOutbound and ServerInfo.outboundIp == r.ip then
                        infoLog("Detected proper differing outbound IP configuration.")
                    else
                        if ServerInfo.differingOutbound then
                            needSetup = true
                            serverObj.outboundIp = r.ip
                        else
                            needSetup = true
                            serverObj.outboundIp = r.ip
                            serverObj.differingOutbound = true
                        end
                    end
                end
            end
            if needSetup then
                local payload = nil
                if ServerInfo == nil then
                    payload = { ["servers"] = {serverObj}}
                else
                    payload = info
                    for k, v in pairs(payload) do
                        if v.id == serverId then
                            payload[k] = serverObj
                        end
                    end
                end
                debugLog(("Send payload: %s"):format(json.encode(payload)))
                performApiRequest(json.encode(payload), "SET_SERVERS", function(resp) 
                    debugLog("SET_SERVERS: "..tostring(resp))
                end)
            end
        end, "GET", nil, nil)
    end)

    if isPluginLoaded("livemap") then
        warnLog("The livemap plugin is no longer being used due to the map being native to the CAD. You can remove this plugin.")
    end
end)

CreateThread(function()
    while Config.apiVersion == -1 do
        Wait(100)
    end
    if Config.critError then return end
    if isPluginLoaded("wraithv2") then
        if GetResourceState("wk_wars2x") ~= "started" then
            warnLog(("Warning: wk_wars2x resource in bad start (%s). Ensure it is started to use the wraithv2 resource."):format(GetResourceState("wk_wars2x")))
        end
        if GetResourceState("pNotify") ~= "started" then
            warnLog(("Warning: pNotify is required to see notifications from the wraithv2 plugin but the resource in bad start (%s). Ensure it is started"):format(GetResourceState("pNotify")))
        end
    end
    if isPluginLoaded("smartsigns") then
        warnLog("smartsigns is now a standalone resource. Please update.")
    end
    -- smartsigns improper install check
    if file_exists(("%s/plugins/smartsigns/sv_smartsigns.lua"):format(GetResourcePath(GetCurrentResourceName()))) or file_exists(("%s/plugins/smartsigns/smartsigns/sv_smartsigns.lua"):format(GetResourcePath(GetCurrentResourceName()))) then
        errorLog("-----------------------")
        errorLog("Smartsigns incorrect installation detected. This should be installed a standalone resource. If you still have the plugin, you MUST update! You will recieve a parse error in this state.")
        errorLog("-----------------------")
    end
end)

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
 end