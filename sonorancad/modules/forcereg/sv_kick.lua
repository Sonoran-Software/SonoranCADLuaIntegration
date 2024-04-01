--[[
        Sonaran CAD Plugins

        Plugin Name: kick
        Creator: Taylor McGaw
        Description: Kicks user from the cad upon exiting the server
    ]]

local pluginConfig = Config.GetPluginConfig('kick')

local UnitCache = {}
if pluginConfig.enabled then

	local PendingKicks = {}
	registerApiType('KICK_UNIT', 'emergency')
	AddEventHandler('playerDropped', function()
		local source = source
		local identifier = GetIdentifiers(source)[Config.PrimaryIdentifier]
		if not identifier then
			debugLog('kick: no API ID, skip')
			return
		end
		UnitCache = GetUnitCache()
		if UnitCache ~= nil and #UnitCache > 0 then
			for _, unit in pairs(UnitCache) do
				if unit.data.apiIds == nil or #unit.data.apiIds == 0 then
					debugLog('kick: no API ID, skip')
					return
				else
					for _, id in ipairs(unit.data.apiIds) do
						if id == identifier then
							debugLog('kick: unit found, kicking')
							table.insert(PendingKicks, identifier)
							break
						end
					end
				end
				debugLog('kick: no unit found, skip')
			end
		end
	end)

	CreateThread(function()
		while true do
			if #PendingKicks > 0 then
				local kicks = {}
				while true do
					local pendingKick = table.remove(PendingKicks)
					if pendingKick ~= nil then
						table.insert(kicks, {
							['apiId'] = pendingKick,
							['reason'] = 'You have exited the server',
							['serverId'] = Config.serverId
						})
					else
						break
					end
				end
				performApiRequest(kicks, 'KICK_UNIT', function()
				end)
			end
			Wait(10000)
		end
	end)
end
