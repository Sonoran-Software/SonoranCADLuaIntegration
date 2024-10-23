--[[
    Sonaran CAD Plugins

    Plugin Name: postals
    Creator: SonoranCAD
    Description: Fetches nearest postal from client
]] -- Toggles Postal Sender
CreateThread(function()
	Config.LoadPlugin('postals', function(pluginConfig)
		local locationsConfig = Config.GetPluginConfig('locations')

		if pluginConfig.enabled and locationsConfig ~= nil then

			local postalFile = nil
			local postals
			local state = GetResourceState(pluginConfig.nearestPostalResourceName)
			local shouldStop = false
			if pluginConfig.mode and pluginConfig.mode == 'resource' then
				if state ~= 'started' then
					if state == 'missing' then
						errorLog(('[postals] The configured postals resource (%s) does not exist. Please check the name.'):format(pluginConfig.nearestPostalResourceName))
						shouldStop = true
					elseif state == 'stopped' then
						warnLog(('[postals] The postals resource (%s) is not started. Please ensure it\'s started before clients conntect. This is only a warning. State: %s'):format(
										pluginConfig.nearestPostalResourceName, state))
					else
						errorLog(('[postals] The configured postals resource (%s) is in a bad state (%s). Please check it.'):format(pluginConfig.nearestPostalResourceName, state))
						shouldStop = true
					end
				end
			elseif pluginConfig.mode and pluginConfig.mode == 'file' then
				local postalFile = LoadResourceFile(GetCurrentResourceName(), ('/submodules/postals/%s'):format(pluginConfig.customPostalCodesFile))
				if postalFile == nil then
					errorLog(('[postals] The configured postals file (%s) was not found. Please check it.'):format(pluginConfig.customPostalCodesFile))
					shouldStop = true
				end
			end
			if shouldStop then
				pluginConfig.enabled = false
				pluginConfig.disableReason = 'postal resource incorrect'
				errorLog('Force disabling plugin to prevent client errors.')
				return
			end

			PostalsCache = {}

			RegisterNetEvent('getShouldSendPostal')
			AddEventHandler('getShouldSendPostal', function()
				TriggerClientEvent('getShouldSendPostalResponse', source, locationsConfig.prefixPostal)
			end)

			RegisterNetEvent('cadClientPostal')
			AddEventHandler('cadClientPostal', function(postal)
				PostalsCache[source] = postal
			end)

			AddEventHandler('playerDropped', function(player)
				PostalsCache[player] = nil
			end)

			function getNearestPostal(player)
				return PostalsCache[player]
			end

			exports('cadGetNearestPostal', getNearestPostal)

			registerApiType('SET_POSTALS', 'general')

			CreateThread(function()
				while Config.apiVersion == -1 do
					Wait(1000)
				end
				if Config.apiVersion < 4 or not Config.apiSendEnabled then
					return
				end
				if pluginConfig.customPostalCodesFile ~= '' and pluginConfig.customPostalCodesFile ~= nil then
					postalFile = LoadResourceFile(GetCurrentResourceName(), ('submodules/postals/%s'):format(pluginConfig.customPostalCodesFile))
				else
					postalFile = LoadResourceFile(pluginConfig.nearestPostalResourceName, GetResourceMetadata(pluginConfig.nearestPostalResourceName, 'postal_file'))
				end
				if postalFile == nil then
					errorLog('Failed to open postals file for reading.')
				else
					performApiRequest(postalFile, 'SET_POSTALS', function()
					end)
					postals = json.decode(postalFile)
					for i, postal in ipairs(postals) do
						postals[i] = {vec(postal.x, postal.y), code = postal.code}
					end
				end
			end)

			function getPostalFromVector3(coords)
				local _total = #postals
				local _nearestIndex, _nearestD
				coords = vector2(coords.x, coords.y)

				for i = 1, _total do
					local D = #(coords - postals[i][1])
					if not _nearestD or D < _nearestD then
						_nearestIndex = i
						_nearestD = D
					end
				end

				return postals[_nearestIndex].code
			end

		elseif locationsConfig == nil then
			errorLog('ERROR: Postals plugin is loaded, but required locations plugin is not. This plugin will not function correctly!')
			pluginConfig.enabled = false
			pluginConfig.disableReason = 'locations plugin missing'
		end

	end)
end)
