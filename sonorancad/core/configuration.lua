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
    latestVersion = '',
    apiVersion = -1,
    plugins = {},
    proxyUrl = ''
}

Config.RegisterPluginConfig = function(pluginName, configs)
    Config.plugins[pluginName] = {}
    for k, v in pairs(configs) do
        Config.plugins[pluginName][k] = v
        -- debugLog(("plugin %s set %s = %s"):format(pluginName, k, v))
    end
    table.insert(Plugins, pluginName)
end

local function CopyFile(old_path, new_path)
    local old_file = io.open(old_path, 'rb')
    local new_file = io.open(new_path, 'wb')
    if not old_file then
        warnLog('Failed to open source file: ' .. old_path ..
                    ' - please check your folder permissions or rename file manually.')
        return false
    end
    if not new_file then
        warnLog('Failed to create target file: ' .. new_path ..
                    ' - please check your folder permissions or rename file manually.')
        old_file:close()
        return false
    end

    local old_file_sz, new_file_sz
    while true do
        local block = old_file:read(2 ^ 13)
        if not block then
            old_file_sz = old_file:seek('end')
            break
        end
        new_file:write(block)
    end
    old_file:close()
    new_file_sz = new_file:seek('end')
    new_file:close()
    if new_file_sz ~= old_file_sz then
        print('File copy size mismatch')
        return false
    end
    return true
end

Config.GetPluginConfig = function(pluginName)
    local correctConfig = nil
    if Config.plugins[pluginName] ~= nil then
        if Config.critError then
            Config.plugins[pluginName].enabled = false
            Config.plugins[pluginName].disableReason = 'startup aborted'
        elseif Config.plugins[pluginName].enabled == nil then
            Config.plugins[pluginName].enabled = true
        end
        return Config.plugins[pluginName]
    else
        if pluginName == 'yourpluginname' then
            return {enabled = false, disableReason = 'Template plugin'}
        end
        if pluginName == 'apicheck' or pluginName == 'livemap' or pluginName ==
            'smartsigns' then
            return {enabled = false, disableReason = 'deprecated plugin'}
        end
        correctConfig = LoadResourceFile(GetCurrentResourceName(),
                                         '/configuration/' .. pluginName ..
                                             '_config.lua')
        if not correctConfig then
            infoLog(
                ('Plugin %s only has the default configurations file (%s_config.dist.lua)... Attempting to rename config to: %s_config.lua'):format(
                    pluginName, pluginName, pluginName))
            if not CopyFile(GetResourcePath(GetCurrentResourceName()) ..
                                '/configuration/' .. pluginName ..
                                '_config.dist.lua',
                            GetResourcePath(GetCurrentResourceName()) ..
                                '/configuration/' .. pluginName .. '_config.lua') then
                warnLog(
                    ('Failed to rename %s_config.dist.lua to %s_config.lua'):format(
                        pluginName, pluginName))
                warnLog(
                    ('Using default configurations for %s. Please rename %s_config.dist.lua to %s_config.lua to avoid seeing this message'):format(
                        pluginName, pluginName, pluginName))
                correctConfig = LoadResourceFile(GetCurrentResourceName(),
                                                 '/configuration/' .. pluginName ..
                                                     '_config.dist.lua')
            else
                correctConfig = LoadResourceFile(GetCurrentResourceName(),
                                                 '/configuration/' .. pluginName ..
                                                     '_config.lua')
            end
        end
        if not correctConfig then
            warnLog(
                ('Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-submodules/integration-submodules/plugin-installation for steps to properly install.'):format(
                    pluginName))
            Config.plugins[pluginName] = {
                enabled = false,
                disableReason = 'Missing configuration file'
            }
            return {
                enabled = false,
                disableReason = 'Missing configuration file'
            }
        else
            local loadedPlugin, pluginError = load(correctConfig)
            if loadedPlugin then
                local success, res = pcall(loadedPlugin)
                if not success then
                    errorLog(
                        ('Plugin %s failed to load due to error: %s'):format(
                            pluginName, res))
                    Config.plugins[pluginName] = {
                        enabled = false,
                        disableReason = 'Failed to load'
                    }
                    return {enabled = false, disableReason = 'Failed to load'}
                end
                if _G.config and type(_G.config) == "table" then
                    -- Assign the extracted config to Config.plugins[pluginName]
                    Config.plugins[pluginName] = _G.config
                else
                    -- Handle case where config is not available
                    errorLog(
                        ('Plugin %s did not define a valid config table.'):format(
                            pluginName))
                    Config.plugins[pluginName] = {
                        enabled = false,
                        disableReason = 'Invalid or missing config'
                    }
                    return {
                        enabled = false,
                        disableReason = 'Invalid or missing config'
                    }
                end
                if Config.critError then
                    Config.plugins[pluginName].enabled = false
                    Config.plugins[pluginName].disableReason = 'startup aborted'
                elseif Config.plugins[pluginName].enabled == nil then
                    Config.plugins[pluginName].enabled = true
                elseif Config.plugins[pluginName].enabled == false then
                    Config.plugins[pluginName].disableReason = 'Disabled'
                end
            else
                errorLog(('Plugin %s failed to load due to error: %s'):format(
                             pluginName, pluginError))
                Config.plugins[pluginName] = {
                    enabled = false,
                    disableReason = 'Failed to load'
                }
                return {enabled = false, disableReason = 'Failed to load'}
            end
            return Config.plugins[pluginName]
        end
        Config.plugins[pluginName] = {
            enabled = false,
            disableReason = 'disabled'
        }
        return {enabled = false, disableReason = 'disabled'}
    end
end

Config.LoadPlugin = function(pluginName, cb)
    local correctConfig = nil
    while Config.apiVersion == -1 do Wait(1) end
    if Config.plugins[pluginName] ~= nil then
        if Config.critError then
            Config.plugins[pluginName].enabled = false
            Config.plugins[pluginName].disableReason = 'startup aborted'
        elseif Config.plugins[pluginName].enabled == nil then
            Config.plugins[pluginName].enabled = true
        end
        return cb(Config.plugins[pluginName])
    else
        if pluginName == 'yourpluginname' then
            return cb({enabled = false, disableReason = 'Template plugin'})
        end
        correctConfig = LoadResourceFile(GetCurrentResourceName(),
                                         '/configuration/' .. pluginName ..
                                             '_config.lua')
        if not correctConfig then
            infoLog(
                ('Plugin %s only has the default configurations file (%s_config.dist.lua)... Attempting to rename config to: %s_config.lua'):format(
                    pluginName, pluginName, pluginName))
            if not CopyFile(GetResourcePath(GetCurrentResourceName()) ..
                                '/configuration/' .. pluginName ..
                                '_config.dist.lua',
                            GetResourcePath(GetCurrentResourceName()) ..
                                '/configuration/' .. pluginName .. '_config.lua') then
                warnLog(
                    ('Failed to rename %s_config.dist.lua to %s_config.lua'):format(
                        pluginName, pluginName))
                warnLog(
                    ('Using default configurations for %s. Please rename %s_config.dist.lua to %s_config.lua to avoid seeing this message'):format(
                        pluginName, pluginName, pluginName))
                correctConfig = LoadResourceFile(GetCurrentResourceName(),
                                                 '/configuration/' .. pluginName ..
                                                     '_config.dist.lua')
            else
                correctConfig = LoadResourceFile(GetCurrentResourceName(),
                                                 '/configuration/' .. pluginName ..
                                                     '_config.lua')
            end
        end
        if not correctConfig then
            warnLog(
                ('Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-submodules/integration-submodules/plugin-installation for steps to properly install.'):format(
                    pluginName))
            Config.plugins[pluginName] = {
                enabled = false,
                disableReason = 'Missing configuration file'
            }
            return cb({
                enabled = false,
                disableReason = 'Missing configuration file'
            })
        else
            local loadedPlugin, pluginError = load(correctConfig)
            if loadedPlugin then
                local success, res = pcall(loadedPlugin)
                if not success then
                    errorLog(
                        ('Plugin %s failed to load due to error: %s'):format(
                            pluginName, res))
                    Config.plugins[pluginName] = {
                        enabled = false,
                        disableReason = 'Failed to load'
                    }
                    return {enabled = false, disableReason = 'Failed to load'}
                end
                if _G.config and type(_G.config) == "table" then
                    -- Assign the extracted config to Config.plugins[pluginName]
                    Config.plugins[pluginName] = _G.config
                else
                    -- Handle case where config is not available
                    errorLog(
                        ('Plugin %s did not define a valid config table.'):format(
                            pluginName))
                    Config.plugins[pluginName] = {
                        enabled = false,
                        disableReason = 'Invalid or missing config'
                    }
                    return cb({
                        enabled = false,
                        disableReason = 'Invalid or missing config'
                    })
                end
                if Config.critError then
                    Config.plugins[pluginName].enabled = false
                    Config.plugins[pluginName].disableReason = 'startup aborted'
                elseif Config.plugins[pluginName].enabled == nil then
                    Config.plugins[pluginName].enabled = true
                elseif Config.plugins[pluginName].enabled == false then
                    Config.plugins[pluginName].disableReason = 'Disabled'
                end
            else
                errorLog(('Plugin %s failed to load due to error: %s'):format(
                             pluginName, pluginError))
                Config.plugins[pluginName] = {
                    enabled = false,
                    disableReason = 'Failed to load'
                }
                return cb({enabled = false, disableReason = 'Failed to load'})
            end
            return cb(Config.plugins[pluginName])
        end
        Config.plugins[pluginName] = {
            enabled = false,
            disableReason = 'disabled'
        }
        return cb({enabled = false, disableReason = 'disabled'})
    end
end

local conf = LoadResourceFile(GetCurrentResourceName(),
                              '/configuration/config.json')
if conf == nil then
    errorLog(
        'CONFIG_ERROR: Unable to load configuration file. Ensure the file is named correctly (config.json). Check for extra extensions (like config.json.json).')
    Config.critError = true
    Config.apiSendEnabled = false
    return
end
local parsedConfig = json.decode(conf)
if parsedConfig == nil then
    errorLog(
        'CONFIG_ERROR: Unable to parse configuration file. Ensure it is valid JSON.')
    Config.critError = true
    Config.apiSendEnabled = false
    return
end
for k, v in pairs(json.decode(conf)) do
    local cvar = GetConvar('sonoran_' .. k, 'NONE')
    local cvar_setter = GetConvar('sonoran_' .. k .. '_setter', 'NONE')
    local val = nil
    if cvar ~= 'NONE' and cvar ~= 'statusLabels' then
        if cvar_setter == 'NONE' or cvar_setter == 'server' then
            infoLog(
                ('Configuration: Overriding config option %s with convar. New value: %s'):format(
                    k, cvar))
            SetConvar('sonoran_' .. k .. '_setter', 'server')
            cvar_setter = 'server'
        else
            infoLog(
                ('Configuration: Reusing config option %s from server boot. New value: %s, reboot the server if you made a change to this value...'):format(
                    k, cvar))
            SetConvar('sonoran_' .. k .. '_setter', 'framework')
            cvar_setter = 'framework'
        end
        if cvar == 'true' then
            cvar = true
        elseif cvar == 'false' then
            cvar = false
        end
        Config[k] = cvar
        val = cvar
    else
        Config[k] = v
        val = v
    end
    if k ~= 'apiKey' then
        SetConvar('sonoran_' .. k, tostring(val))
        if cvar_setter == 'NONE' then
            SetConvar('sonoran_' .. k .. '_setter', 'framework')
        end
    end
end

if Config.updateBranch == nil then Config.updateBranch = 'master' end

if GetConvar('web_baseUrl', '') ~= '' then
    Config.proxyUrl = ('https://%s/sonorancad/'):format(
                          GetConvar('web_baseUrl', ''))
end

RegisterNetEvent('SonoranCAD::core:sendClientConfig')
AddEventHandler('SonoranCAD::core:sendClientConfig', function()
    local config = {
        communityID = Config.communityID,
        postTime = Config.postTime,
        serverId = Config.serverId,
        primaryIdentifier = Config.primaryIdentifier,
        apiSendEnabled = Config.apiSendEnabled,
        debugMode = Config.debugMode,
        devHiddenSwitch = Config.devHiddenSwitch,
        statusLabels = Config.statusLabels,
        bodycamEnabled = Config.bodycamEnabled,
        bodycamBeepFrequency = Config.bodycamBeepFrequency,
        bodycamScreenshotFrequency = Config.bodycamScreenshotFrequency,
        bodycamPlayBeeps = Config.bodycamPlayBeeps,
        bodycamOverlayEnabled = Config.bodycamOverlayEnabled,
        bodycamOverlayLocation = Config.bodycamOverlayLocation,
        bodycamCommandToggle = Config.bodycamCommandToggle,
        bodycamCommandChangeFrequncy = Config.bodycamCommandChangeFrequncy,
        apiVersion = Config.apiVersion
    }
    TriggerClientEvent('SonoranCAD::core:recvClientConfig', source, config)
end)

CreateThread(function()
    Wait(2000) -- wait for server to settle
    if Config.critError then return end
    local serverId = Config.serverId
    while Config.apiVersion == -1 do Wait(10) end
    if not Config.apiSendEnabled or Config.apiVersion < 3 then
        debugLog('Too low version or API disabled, ignore this')
        return
    end
    performApiRequest({}, 'GET_SERVERS', function(response)
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
                name = 'Server ' .. serverId,
                description = 'Server ' .. serverId,
                signal = '',
                listenerPort = GetConvar('netPort', '0'),
                mapIp = '',
                differingOutbound = false,
                outboundIp = '',
                enableMap = true,
                mapType = 'NORMAL'
            }
        else
            serverObj = ServerInfo
        end
        if serverObj.name == '' then
            serverObj.name = 'Server ' .. tostring(serverId)
        end
        if ServerInfo.listenerPort ~= GetConvar('netPort', '0') then
            infoLog(
                ('Configuration information doesn\'t match, will attempt to auto-correct game port from %s to %s.'):format(
                    ServerInfo.listenerPort, GetConvar('netPort', '0')))
            serverObj.listenerPort = GetConvar('netPort', '0')
            needSetup = true
        end
        PerformHttpRequest('https://api.ipify.org?format=json',
                           function(errorCode, resultData, resultHeaders)
            local r = json.decode(resultData)
            if r ~= nil and r.ip ~= nil then
                debugLog(
                    ('IP DETECT - IP: %s - Detected: %s - Outbound set: %s - Outbound IP: %s'):format(
                        ServerInfo.mapIp, r.ip, ServerInfo.differingOutbound,
                        ServerInfo.outboundIp))
                if serverObj.mapIp == '' or serverObj.mapIp == nil then
                    serverObj.mapIp = r.ip
                    needSetup = true
                end
                if ServerInfo.mapIp ~= r.ip then
                    if ServerInfo.differingOutbound and ServerInfo.outboundIp ==
                        r.ip then
                        infoLog(
                            'Detected proper differing outbound IP configuration.')
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
            local disableOverride = (Config.disableOverride ~= nil and
                                        Config.disableOverride or false)
            if needSetup and not disableOverride then
                local payload = nil
                if ServerInfo == nil then
                    payload = {['servers'] = {serverObj}}
                else
                    payload = info
                    for k, v in pairs(payload) do
                        if v.id == serverId then
                            payload[k] = serverObj
                        end
                    end
                end
                debugLog(('Send payload: %s'):format(json.encode(payload)))
                performApiRequest(json.encode(payload), 'SET_SERVERS', function(
                    resp)
                    debugLog('SET_SERVERS: ' .. tostring(resp))
                end)
            else
                warnLog(
                    'disableOverride is true, skipping any potential auto-IP/port fixing')
            end
        end, 'GET', nil, nil)
    end)

    if isPluginLoaded('livemap') then
        warnLog(
            'The livemap plugin is no longer being used due to the map being native to the CAD. You can remove this plugin.')
    end

    local attempts = 0
    local max_retries = 20
    while attempts <= max_retries do
        Wait(1000)
        attempts = attempts + 1
        if attempts == max_retries then
            errorLog(
                'Failed to initialize bodycam due to missing web_baseUrl convar.')
        end
        if GetConvar('web_baseUrl', '') ~= '' then
            TriggerClientEvent('SonoranCAD::Core::InitBodycam', -1)
            Config.proxyUrl = ('https://%s/sonorancad/'):format(GetConvar(
                                                                    'web_baseUrl',
                                                                    ''))
            break
        end
    end
end)

RegisterNetEvent('SonoranCAD::Core::RequestBodycam', function()
    local attempts = 0
    local max_retries = 20
    local source = source
    if Config.proxyUrl ~= '' then
        TriggerClientEvent('SonoranCAD::Core::InitBodycam', source)
    else
        while attempts <= max_retries do
            Wait(1000)
            attempts = attempts + 1
            if attempts == max_retries then
                errorLog(
                    'Failed to initialize bodycam due to missing web_baseUrl convar.')
            end
            if GetConvar('web_baseUrl', '') ~= '' then
                TriggerClientEvent('SonoranCAD::Core::InitBodycam', source)
                break
            end
        end
    end
end)

CreateThread(function()
    while Config.apiVersion == -1 do Wait(100) end
    if Config.critError then return end
    if isPluginLoaded('wraithv2') then
        if GetResourceState('wk_wars2x') ~= 'started' then
            warnLog(
                ('Warning: wk_wars2x resource in bad start (%s). Ensure it is started to use the wraithv2 resource.'):format(
                    GetResourceState('wk_wars2x')))
        end
        if GetResourceState('pNotify') ~= 'started' then
            warnLog(
                ('Warning: pNotify is required to see notifications from the wraithv2 plugin but the resource in bad start (%s). Ensure it is started'):format(
                    GetResourceState('pNotify')))
        end
    end
    if isPluginLoaded('smartsigns') then
        warnLog('smartsigns is now a standalone resource. Please update.')
    end
    -- smartsigns improper install check
    if file_exists(('%s/submodules/smartsigns/sv_smartsigns.lua'):format(
                       GetResourcePath(GetCurrentResourceName()))) or
        file_exists(
            ('%s/submodules/smartsigns/smartsigns/sv_smartsigns.lua'):format(
                GetResourcePath(GetCurrentResourceName()))) then
        errorLog('-----------------------')
        errorLog(
            'Smartsigns incorrect installation detected. This should be installed a standalone resource. If you still have the plugin, you MUST update! You will recieve a parse error in this state.')
        errorLog('-----------------------')
    end
end)

function file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end
