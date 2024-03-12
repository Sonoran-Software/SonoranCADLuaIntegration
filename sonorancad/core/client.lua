Config = {
	plugins = {}
}
Plugins = {}

local bodyCamOn = false;
local bodyCamFrequency = 2000
local bodyCamConfigReady = false;

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
			Config.plugins[pluginName].disableReason = 'startup aborted'
		elseif Config.plugins[pluginName].enabled == nil then
			Config.plugins[pluginName].enabled = true
		elseif Config.plugins[pluginName].enabled == false then
			Config.plugins[pluginName].disableReason = 'Disabled'
		end
		return Config.plugins[pluginName]
	else
		if pluginName == 'yourpluginname' then
			return {
				enabled = false,
				disableReason = 'Template plugin'
			}
		end
		if not LoadResourceFile(GetCurrentResourceName(), ('plugins/%s/%s/config_%s.lua'):format(pluginName, pluginName, pluginName))
						and not LoadResourceFile(GetCurrentResourceName(), ('plugins/%s/config_%s.lua'):format(pluginName, pluginName)) then
			warnLog(
							('Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-plugins/integration-plugins/plugin-installation for steps to properly install.'):format(
											pluginName))
		end
		Config.plugins[pluginName] = {
			enabled = false,
			disableReason = 'Missing configuration file'
		}
		return {
			enabled = false,
			disableReason = 'Missing configuration file'
		}
	end
end

Config.LoadPlugin = function(pluginName, cb)
	while Config.apiVersion == -1 do
		Wait(1)
	end
	if Config.plugins[pluginName] ~= nil then
		if Config.critError then
			Config.plugins[pluginName].enabled = false
			Config.plugins[pluginName].disableReason = 'startup aborted'
		elseif Config.plugins[pluginName].enabled == nil then
			Config.plugins[pluginName].enabled = true
		elseif Config.plugins[pluginName].enabled == false then
			Config.plugins[pluginName].disableReason = 'Disabled'
		end
		return cb(Config.plugins[pluginName])
	else
		if pluginName == 'yourpluginname' then
			return cb({
				enabled = false,
				disableReason = 'Template plugin'
			})
		end
		if not LoadResourceFile(GetCurrentResourceName(), ('plugins/%s/%s/config_%s.lua'):format(pluginName, pluginName, pluginName))
						and not LoadResourceFile(GetCurrentResourceName(), ('plugins/%s/config_%s.lua'):format(pluginName, pluginName)) then
			warnLog(
							('Plugin %s is missing critical configuration. Please check our plugin install guide at https://info.sonorancad.com/integration-plugins/integration-plugins/plugin-installation for steps to properly install.'):format(
											pluginName))
		end
		Config.plugins[pluginName] = {
			enabled = false,
			disableReason = 'Missing configuration file'
		}
		return cb({
			enabled = false,
			disableReason = 'Missing configuration file'
		})
	end
end

CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Wait(1)
	end
	TriggerServerEvent('SonoranCAD::core:sendClientConfig')
end)

RegisterNetEvent('SonoranCAD::core:recvClientConfig')
AddEventHandler('SonoranCAD::core:recvClientConfig', function(config)
	for k, v in pairs(config) do
		Config[k] = v
	end
	Config.inited = true
	debugLog('Configuration received')
	debugLog('Bodycam config ready')
	Wait(5000)
	-- Command to toggle bodycam on and off
	RegisterCommand(Config.bodycamCommandToggle, function(source, args, rawCommand)
		if Config.apiVersion > 4 then
			errorLog('Bodycam is only enabled with Sonoran CAD Pro.')
			TriggerEvent('chat:addMessage', {
				args = {
					'Sonoran Bodycam',
					'Bodycam is only enabled with Sonoran CAD Pro.'
				}
			})
			return
		end
		if bodyCamOn then
			bodyCamOn = false
			TriggerEvent('chat:addMessage', {
				args = {
					'Sonoran Bodycam',
					'Bodycam disabled.'
				}
			})
		else
			bodyCamOn = true
			TriggerEvent('chat:addMessage', {
				args = {
					'Sonoran Bodycam',
					'Bodycam enabled.'
				}
			})
		end
	end, false)
	-- Command to change the frequency of bodycam screenshots
	RegisterCommand(Config.bodycamCommandChangeFrequncy, function(source, args, rawCommand)
		if Config.apiVersion > 4 then
			errorLog('Bodycam is only enabled with Sonoran CAD Pro.')
			TriggerEvent('chat:addMessage', {
				args = {
					'Sonoran Bodycam',
					'Bodycam is only enabled with Sonoran CAD Pro.'
				}
			})
			return
		end
		if args[1] then
			args[1] = tonumber(args[1])
			if not args[1] or args[1] < 2 or args[1] > 10 then
				errorLog('Frequency must a number greater than 1 and less than than 10 seconds.')
				TriggerEvent('chat:addMessage', {
					args = {
						'Sonoran Bodycam',
						'Frequency must a number greater than 0 and less than than 10 seconds.'
					}
				})
				return
			end
			bodyCamFrequency = tonumber(args[1])
			TriggerEvent('chat:addMessage', {
				args = {
					'Sonoran Bodycam',
					('Frequency set to %s.'):format(bodyCamFrequency)
				}
			})
		else
			TriggerEvent('chat:addMessage', {
				args = {
					'Sonoran Bodycam',
					('Current bodycam frequency is %s.'):format(bodyCamFrequency)
				}
			})
		end
	end, false)
	-- Add suggestions to the chat
	TriggerEvent('chat:addSuggestion', '/' .. Config.bodycamCommandToggle, 'Enable or disable bodycam mode.')
	TriggerEvent('chat:addSuggestion', '/' .. Config.bodycamCommandChangeFrequncy, 'Change the frequency of bodycam screenshots.', {
		{
			name = 'frequency',
			help = 'Frequency in seconds.'
		}
	})
end)

CreateThread(function()
	while not Config.inited do
		Wait(10)
	end
	if Config.devHiddenSwitch then
		debugLog('Spawned discord thread')
		SetDiscordAppId(867548404724531210)
		SetDiscordRichPresenceAsset('icon')
		SetDiscordRichPresenceAssetSmall('icon')
		while true do
			SetRichPresence('Developing SonoranCAD!')
			Wait(5000)
			SetRichPresence('sonorancad.com')
			Wait(5000)
		end
	end
end)

local inited = false
AddEventHandler('playerSpawned', function()
	TriggerServerEvent('SonoranCAD::core:PlayerReady')
	inited = true
end)

RegisterNetEvent('SonoranCAD::core:debugModeToggle')
AddEventHandler('SonoranCAD::core:debugModeToggle', function(toggle)
	Config.debugMode = toggle
end)

RegisterNetEvent('SonoranCAD::core:AddPlayer')
RegisterNetEvent('SonoranCAD::core:RemovePlayer')

--[[
    SonoranCAD Bodycam Plugin
]]

-- Main bodycam loops
CreateThread(function()
	while true do
		Wait(1)
		if bodyCamOn then
			TriggerServerEvent('SonoranCAD::core:TakeScreenshot')
			Wait(bodyCamFrequency)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(1)
		if Config.bodycamPlayBeeps then
			if bodyCamOn then
				-- PLAY BEEPS
				Wait(Config.bodycamBeepFrequency)
			end
		end
	end
end)
