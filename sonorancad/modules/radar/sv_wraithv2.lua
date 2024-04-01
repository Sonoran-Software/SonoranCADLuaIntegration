--[[
    Sonaran CAD Plugins

    Plugin Name: wraithv2
    Creator: SonoranCAD
    Description: Implements plate auto-lookup for the wraithv2 plate reader by WolfKnight

    Put all server-side logic in this file.
]] local pluginConfig = Config.GetPluginConfig('wraithv2')

if pluginConfig.enabled then

	if pluginConfig.useExpires == nil then
		pluginConfig.useExpires = true
	end
	if pluginConfig.useMiddleInitial == nil then
		pluginConfig.useMiddleInitial = true
	end

	wraithLastPlates = {locked = nil, scanned = nil}

	exports('cadGetLastPlates', function()
		return wraithLastPlates
	end)

	local function isInArray(array, value)
		for i = 1, #array do
			if array[i] == value then
				return true
			end
		end
		return false
	end

	RegisterNetEvent('wk:onPlateLocked')
	AddEventHandler('wk:onPlateLocked', function(cam, plate, index, vehicle, cbType, returnEvent)
		debugLog(('plate lock: %s - %s - %s - %s - %s'):format(cam, plate, index, cbType, returnEvent))
		local source = source
		local ids = GetIdentifiers(source)
		plate = plate:match('^%s*(.-)%s*$')
		wraithLastPlates.locked = {cam = cam, plate = plate, index = index, vehicle = cam.vehicle}
		cadGetInformation(plate, function(regData, vehData, charData, boloData)
			if cam == 'front' then
				camCapitalized = 'Front'
			elseif cam == 'rear' then
				camCapitalized = 'Rear'
			end
			if returnEvent ~= nil then
				if cbType == 'client' then
					TriggerClientEvent(returnEvent, source, {['regData'] = regData, ['vehData'] = vehData, ['charData'] = charData, ['boloData'] = boloData, ['plate'] = plate, ['cam'] = cam, ['index'] = index})
				elseif cbType == 'server' then
					TriggerServerEvent(returnEvent, source, {['regData'] = regData, ['vehData'] = vehData, ['charData'] = charData, ['boloData'] = boloData, ['plate'] = plate, ['cam'] = cam, ['index'] = index})
				else
					warnLog('The provided cbType for wk:onPlateLocked was invalid!')
				end
			end
			if #vehData < 1 then
				debugLog('No data returned')
				return
			end
			local reg = false
			for _, veh in pairs(vehData) do
				if veh.plate:lower() == plate:lower() then
					reg = veh
					break
				end
			end
			if #charData < 1 then
				debugLog('Invalid registration')
				return
			end
			local person = charData[1]
			if reg then
				TriggerEvent('SonoranCAD::wraithv2:PlateLocked', source, reg, cam, plate, index)
				local plate = reg.plate
				if regData == nil then
					debugLog('regData is nil, skipping plate lock.')
					return
				end
				if regData[1] == nil then
					debugLog('regData is empty, skipping')
					return
				end
				if regData[1].status == nil then
					warnLog(('Plate %s was scanned by %s, but status was nil. Record: %s'):format(plate, source, json.encode(regData[1])))
					return
				end
				local plate = reg.plate
				local statusUid = pluginConfig.statusUid ~= nil and pluginConfig.statusUid or 'status'
				local expiresUid = pluginConfig.expiresUid ~= nil and pluginConfig.expiresUid or 'expiration'
				local status = regData[1][statusUid]
				local expires = (regData[1][expiresUid] and pluginConfig.useExpires) and ('Expires: %s<br/>'):format(regData[1][expiresUid]) or ''
				local owner = (pluginConfig.useMiddleInitial and person.mi ~= '') and ('%s %s, %s'):format(person.first, person.last, person.mi) or ('%s %s'):format(person.first, person.last)
				TriggerClientEvent('pNotify:SendNotification', source,
				                   {text = ('<b style=\'color:yellow\'>' .. camCapitalized .. ' ALPR</b><br/>Plate: %s<br/>Status: %s<br/>%sOwner: %s'):format(plate:upper(), status, expires, owner),
					type = 'success', queue = 'alpr', timeout = 30000, layout = 'centerLeft'})
				if #boloData > 0 then
					local flags = table.concat(boloData, ',')
					TriggerClientEvent('pNotify:SendNotification', source, {text = ('<b style=\'color:red\'>BOLO ALERT!<br/>Plate: %s<br/>Flags: %s'):format(plate:upper(), flags), type = 'error', queue = 'bolo',
						timeout = 20000, layout = 'centerLeft'})
				end
			else
				TriggerClientEvent('pNotify:SendNotification', source,
				                   {text = '<b style=\'color:yellow\'>' .. camCapitalized .. ' ALPR</b><br/>Plate: ' .. plate:upper() .. '<br/>Status: Not Registered', type = 'error', queue = 'alpr',
					timeout = 15000, layout = 'centerLeft'})
			end
		end, ids[Config.PrimaryIdentifier])
	end)

	RegisterNetEvent('wk:onPlateScanned')
	AddEventHandler('wk:onPlateScanned', function(cam, plate, index, vehicle, cbType, returnEvent)
		local vehicleClass = tonumber(vehicle.class)
		if isInArray(pluginConfig.vehTypeFilter, vehicleClass) then
			debugLog(('Vehicle type %s is filtered, skipping plate scan'):format(vehicleClass))
			return
		end
		if cam == 'front' then
			camCapitalized = 'Front'
		elseif cam == 'rear' then
			camCapitalized = 'Rear'
		end
		debugLog(('plate scan: %s - %s - %s - %s - %s'):format(cam, plate, index, cbType, returnEvent))
		local source = source
		plate = plate:match('^%s*(.-)%s*$')
		wraithLastPlates.scanned = {cam = cam, plate = plate, index = index, vehicle = cam.vehicle}
		TriggerEvent('SonoranCAD::wraithv2:PlateScanned', source, reg, cam, plate, index)
		cadGetInformation(plate, function(regData, vehData, charData, boloData)
			if returnEvent ~= nil then
				if cbType == 'client' then
					TriggerClientEvent(returnEvent, source, {['regData'] = regData, ['vehData'] = vehData, ['charData'] = charData, ['boloData'] = boloData, ['plate'] = plate, ['cam'] = cam, ['index'] = index})
				elseif cbType == 'server' then
					TriggerServerEvent(returnEvent, source, {['regData'] = regData, ['vehData'] = vehData, ['charData'] = charData, ['boloData'] = boloData, ['plate'] = plate, ['cam'] = cam, ['index'] = index})
				else
					warnLog('The provided cbType for wk:onPlateLocked was invalid!')
				end
			end
			if cam == 'front' then
				camCapitalized = 'Front'
			elseif cam == 'rear' then
				camCapitalized = 'Rear'
			end
			local reg = false
			for _, veh in pairs(vehData) do
				if veh.plate:lower() == plate:lower() then
					reg = veh
					break
				end
			end
			local person = {}
			if #charData > 0 then
				person = charData[1]
			end
			if reg then
				TriggerEvent('SonoranCAD::wraithv2:PlateLocked', source, reg, cam, plate, index)
				local plate = reg.plate
				if regData == nil then
					debugLog('regData is nil, skipping plate lock.')
					return
				end
				if regData[1] == nil then
					debugLog('regData is empty, skipping')
					return
				end
				if regData[1].status == nil then
					warnLog(('Plate %s was scanned by %s, but status was nil. Record: %s'):format(plate, source, json.encode(regData[1])))
					return
				end
				local statusUid = pluginConfig.statusUid ~= nil and pluginConfig.statusUid or 'status'
				local expiresUid = pluginConfig.expiresUid ~= nil and pluginConfig.expiresUid or 'expiration'
				local flagStatuses = pluginConfig.flagOnStatuses ~= nil and pluginConfig.flagOnStatuses or {'STOLEN', 'EXPIRED', 'PENDING', 'SUSPENDED'}
				local status = regData[1][statusUid]
				local expires = (regData[1][expiresUid] and pluginConfig.useExpires) and ('Expires: %s<br/>'):format(regData[1][expiresUid]) or ''
				local owner = (pluginConfig.useMiddleInitial and person.mi ~= '') and ('%s %s, %s'):format(person.first, person.last, person.mi) or ('%s %s'):format(person.first, person.last)
				if status ~= nil and has_value(flagStatuses, status) then
					TriggerClientEvent('pNotify:SendNotification', source,
					                   {text = ('<b style=\'color:yellow\'>' .. camCapitalized .. ' ALPR</b><br/>Plate: %s<br/>Status: %s<br/>%sOwner: %s'):format(plate:upper(), status, expires, owner),
						type = 'success', queue = 'alpr', timeout = 10000, layout = 'centerLeft'})
					TriggerEvent('SonoranCAD::wraithv2:BadStatus', plate, status, regData[1][expiresUid], owner)
				end
				if #boloData > 0 then
					local flags = table.concat(boloData, ',')
					TriggerClientEvent('pNotify:SendNotification', source, {text = ('<b style=\'color:red\'>BOLO ALERT!<br/>Plate: %s<br/>Flags: %s'):format(plate:upper(), flags), type = 'error', queue = 'bolo',
						timeout = 20000, layout = 'centerLeft'})
					TriggerEvent('SonoranCAD::wraithv2:BoloAlert', plate, flags)
				end
			else
				if pluginConfig.alertNoRegistration then
					TriggerClientEvent('pNotify:SendNotification', source,
					                   {text = '<b style=\'color:yellow\'>' .. camCapitalized .. ' ALPR</b><br/>Plate: ' .. plate:upper() .. '<br/>Status: Not Registered', type = 'warning', queue = 'alpr',
						timeout = 5000, layout = 'centerLeft'})
					TriggerEvent('SonoranCAD::wraithv2:NoRegAlert', plate)
				end
			end
		end)
	end)

end
