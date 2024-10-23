--[[
    Sonaran CAD Plugins

    Plugin Name: postals
    Creator: SonoranCAD
    Description: Fetches nearest postal from client
]]

CreateThread(function()
	Config.LoadPlugin('postals', function(pluginConfig)
		local lastPostal = nil
		local eventPostal = nil
		if pluginConfig.enabled then
			-- Don't touch this!
			function getNearestPostal()
				if pluginConfig.mode and pluginConfig.mode == 'event' then
					return eventPostal
				elseif pluginConfig.mode and pluginConfig.mode == 'file' then
					local postalFile = LoadResourceFile(GetCurrentResourceName(), ('/submodules/postals/%s'):format(pluginConfig.customPostalCodesFile))
					if postalFile ~= nil then
						local postalData = json.decode(postalFile)
                        for i, postal in ipairs(postalData) do postalData[i] = { vec(postal.x, postal.y), code = postal.code } end
                        local coords = GetEntityCoords(PlayerPedId())
                        local _nearestIndex, _nearestD
                        coords = vec(coords[1], coords[2])
                        local _total = #postalData
                        for i = 1, _total do
                            local D = #(coords - postalData[i][1])
                            if not _nearestD or D < _nearestD then
                                _nearestIndex = i
                                _nearestD = D
                            end
                        end
                        local _code = postalData[_nearestIndex].code
						return _code
					else
						assert(false, 'Custom postal file not found. Cannot use postals plugin.')
					end
				else
					if exports[pluginConfig.nearestPostalResourceName] ~= nil then
						local p = exports[pluginConfig.nearestPostalResourceName]:getPostal()
						return p
					else
						assert(false, 'Required postal resource is not loaded. Cannot use postals plugin.')
					end
				end
			end
			if pluginConfig.mode and pluginConfig.nearestPostalEvent and pluginConfig.mode == 'event' then
				AddEventHandler(pluginConfig.nearestPostalEvent, function(postal)
					eventPostal = postal
				end)
			end
			local function sendPostalData()
				local postal = getNearestPostal()
				if postal ~= nil and postal ~= lastPostal then
					TriggerServerEvent('cadClientPostal', postal)
					lastPostal = postal
				end
			end
			CreateThread(function()
				while not NetworkIsPlayerActive(PlayerId()) or pluginConfig.sendTimer == nil do
					Wait(10)
				end
				TriggerServerEvent('getShouldSendPostal')
				while true do
					if pluginConfig.shouldSendPostalData then
						sendPostalData()
					end
					Wait(pluginConfig.sendTimer)
				end
			end)
			RegisterNetEvent('getShouldSendPostalResponse')
			AddEventHandler('getShouldSendPostalResponse', function(toggle)
				print('got ' .. tostring(toggle))
				pluginConfig.shouldSendPostalData = toggle
			end)
		end
	end)
end)
