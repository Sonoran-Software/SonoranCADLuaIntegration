local PluginHttpHandlers = {}
local PluginFilePaths = {}

function RegisterPluginHttpEvent(eventName, func)
	if PluginHttpHandlers[eventName] ~= nil then
		errorLog('Failed to register plugin event ' .. eventName .. ': Already Exists')
		return
	end
	PluginHttpHandlers[eventName] = func
end

local PushEventHandler = {
	EVENT_UNIT_STATUS = function(body)
		if (not body.data.identIds) then
			return false, 'missing identIds'
		end
		if body.data.identIds ~= nil then
			for i = 1, #body.data.identIds do
				local unit = GetUnitObjectById(body.data.identIds[i])
				if unit then
					unit.status = body.data.status
					SetUnitCache(body.data.identIds[i], unit)
					TriggerEvent('SonoranCAD::pushevents:UnitUpdate', unit, unit.status)
					TriggerEvent('SonoranCAD::pushevents:UnitStatusUpdate', unit, unit.status)
					return true
				end
				debugLog(('EVENT_UNIT_STATUS: Unknown unit, idents: %s'):format(json.encode(body.data.identIds)))
				return false, 'unknown unit'
			end
		else
			return false, 'invalid, no idents'
		end
		return true
	end,
	EVENT_UNIT_LOGIN = function(body)
		if (not body.data.unit.id) then
			return false, 'missing ID'
		end
		local unit = body.data.unit
		debugLog('Got a unit: ' .. json.encode(unit))
		unit.isDispatch = body.data.isDispatch
		SetUnitCache(unit.id, unit)
		TriggerEvent('SonoranCAD::pushevents:UnitLogin', unit)
		return true
	end,
	EVENT_UNIT_LOGOUT = function(body)
		if (not body.data.identId) then
			return false, 'missing identId'
		end
		debugLog('UNIT_LOGOUT: ' .. json.encode(body.data))
		TriggerEvent('SonoranCAD::pushevents:UnitLogout', body.data.identId)
		SetUnitCache(GetUnitById(body.data.identId), nil)
		return true
	end,
	EVENT_DISPATCH_NEW = function(body)
		SetCallCache(body.data.dispatch.callId, {
			dispatch_type = 'CALL_NEW',
			dispatch = body.data.dispatch ~= nil and body.data.dispatch or body.data
		})
		TriggerEvent('SonoranCAD::pushevents:DispatchEvent', GetCallCache()[body.data.dispatch.callId])
		return true
	end,
	EVENT_DISPATCH_EDIT = function(body)
		TriggerEvent('SonoranCAD::pushevents:DispatchEdit', GetCallCache()[body.data.dispatch.callId], body.data)
		SetCallCache(body.data.dispatch.callId, {
			dispatch_type = 'CALL_EDIT',
			dispatch = body.data.dispatch ~= nil and body.data.dispatch or body.data
		})
		TriggerEvent('SonoranCAD::pushevents:DispatchEvent', GetCallCache()[body.data.dispatch.callId])
		return true
	end,
	EVENT_DISPATCH_CLOSED = function(body)
		for i = 1, #body.data.callIds do
			local id = body.data.callIds[i]
			if GetCallCache()[id] ~= nil then
				local call = GetCallCache()[id].dispatch
				local d = {
					dispatch_type = 'CALL_CLOSE',
					dispatch = call.dispatch ~= nil and call.dispatch or call
				}
				d.dispatch.status = 2 -- make sure its updated to closed status
				SetCallCache(id, d)
				TriggerEvent('SonoranCAD::pushevents:DispatchEvent', d)
				return true
			else
				debugLog(('Unknown call close (call ID %s), current cache: %s'):format(id, json.encode(CallCache)))
				return false, 'unknown call close'
			end
		end
	end,
	EVENT_DISPATCH_NOTE = function(body)
		TriggerEvent('SonoranCAD::pushevents:DispatchNote', GetCallCache()[body.data.callId], body.data)
		if GetCallCache()[body.data.callId] ~= nil then
			local call = GetCallCache()[body.data.callId].dispatch
			local newnotes = {}
			table.insert(newnotes, body.data.note)
			if call.notes ~= nil then
				for k, v in pairs(call.notes) do
					table.insert(newnotes, v)
				end
			end
			call.notes = newnotes
			SetCallCache(body.data.callId, {
				dispatch_type = 'CALL_EDIT',
				dispatch = call.dispatch ~= nil and call.dispatch or call
			})
			return true
		else
			debugLog(('Unknown call note update (call ID %s), current cache: %s'):format(body.data.callId, json.encode(CallCache)))
			return false, 'unknown call note'
		end
	end,
	EVENT_DISPATCH_UNIT_ATTACH = function(body)
		-- fetch the call and unit data
		local call = GetCallCache()[body.data.callId]
		if body.data.idents ~= nil then
			idents = body.data.idents
		elseif body.data.ident ~= nil then
			table.insert(idents, body.data.ident)
		end
		for i = 1, #idents do
			local unit = GetUnitById(idents[i])
			debugLog('UNIT: ' .. json.encode(unit))
			if call and unit then
				TriggerEvent('SonoranCAD::pushevents:UnitAttach', call, GetUnitCache()[unit])
				local idx = nil
				for x = 1, #call.dispatch.idents do
					if call.dispatch.idents[x] == idents[i] then
						idx = x
					end
				end
				debugLog('INDEX VALUE: ' .. tostring(idx))
				if idx == nil then
					table.insert(call.dispatch.idents, idents[i])
					SetCallCache(body.data.callId, {
						dispatch_type = 'CALL_EDIT',
						dispatch = call.dispatch ~= nil and call.dispatch or call
					})
				end
			else
				debugLog(('Attach failure, unknown call or unit (C: %s) (U: %s)'):format(json.encode(call), json.encode(unit)))
				return false, 'invalid call or unit'
			end
		end
		return true
	end,
	EVENT_DISPATCH_UNIT_DETACH = function(body)
		local call = GetCallCache()[body.data.callId]
		local idents = {}
		if body.data.idents ~= nil then
			idents = body.data.idents
		elseif body.data.ident ~= nil then
			table.insert(idents, body.data.ident)
		end
		for i = 1, #idents do
			local unit = GetUnitById(idents[i])
			if call and unit then
				TriggerEvent('SonoranCAD::pushevents:UnitDetach', call, GetUnitCache()[unit])
				local idx = nil
				for x = 1, #call.dispatch.idents do
					if call.dispatch.idents[x] == idents[i] then
						idx = x
					end
				end
				if unit ~= nil then
					table.remove(call.dispatch.idents, idx)
					SetCallCache(body.data.callId, {
						dispatch_type = 'CALL_EDIT',
						dispatch = call.dispatch ~= nil and call.dispatch or call
					})
				end
			else
				debugLog(('Detach failure, unknown call or unit (C: %s) (U: %s)'):format(json.encode(call), json.encode(unit)))
				return false, 'invalid call or unit'
			end
		end
		return true
	end,
	GET_LOGS = function(body)
		TriggerEvent('SonoranCAD::pushevents:SendSupportLogs', body.logKey)
		return true
	end,
	EVENT_911 = function(body)
		SetEmergencyCache(body.data.call.callId, body.data.call)
		TriggerEvent('SonoranCAD::pushevents:IncomingCadCall', body.data.call, body.data.call.metaData, body.data.apiIds)
		return true
	end,
	EVENT_REMOVE_911 = function(body)
		for i = 1, #body.data.callIds do
			if body.data.callIds[i] then
				SetEmergencyCache(body.data.callIds[i], nil)
				TriggerEvent('SonoranCAD::pushevents:CadCallRemoved', body.data.callIds[i])
			end
		end
		return true
	end,
	EVENT_UNIT_PANIC = function(body)
		local identIds = body.data.identIds or {}
		-- for legacy
		if body.data.identId then
			table.insert(identIds, body.data.identId)
		end

		for _, identId in ipairs(identIds) do
			local unit = GetUnitById(identId)
			if unit then
				TriggerEvent('SonoranCAD::pushevents:UnitPanic', unit, identId, body.data.isPanic)
			else
				debugLog(('Ignore panic event, unit ident %s not found'):format(tostring(identId)))
			end
		end
	end,
	EVENT_STREETSIGN_UPDATED = function(body)
		if body == nil or body.data == nil or body.data.signData == nil then
			return false, 'invalid data'
		end
		TriggerEvent('SonoranCAD::pushevents:SmartSignUpdate', body.data.signData)
		return true
	end,
	EVENT_RECORD_ADD = function(body)
		TriggerEvent('SonoranCAD::pushevents:RecordAdded', body.data.record)
		return true
	end,
	EVENT_RECORD_EDIT = function(body)
		TriggerEvent('SonoranCAD::pushevents:RecordEdited', body.data.record)
		return true
	end,
	EVENT_RECORD_REMOVE = function(body)
		TriggerEvent('SonoranCAD::pushevents:RecordRemoved', body.data.record)
		return true
	end,
	EVENT_UNIT_GROUP_ADD = function(body)
		local idents = {}
		if body.identId ~= nil then
			table.insert(idents, body.identId)
		elseif body.identIds ~= nil then
			for _, v in pairs(body.identIds) do
				table.insert(idents, v)
			end
		else
			return false, 'invalid data'
		end
		local payload = {
			groupName = body.data.groupName,
			idents = idents
		}
		TriggerEvent('SonoranCAD::pushevents:UnitGroupAdd', payload)
		return true
	end,
	EVENT_UNIT_GROUP_REMOVE = function(body)
		TriggerEvent('SonoranCAD::pushevents:UnitGroupRemove', body.data)
		return true
	end,
	EVENT_TONE = function(body)
		TriggerEvent('SonoranCAD::pushevents:Tone', body.data)
		return true
	end
}

SetHttpHandler(function(req, res)
	local path = req.path
	local method = req.method
	local base = ''
	local file = ''
	for word in path:gmatch('[^/]+') do
		if base == '' then
			base = word
		elseif file == '' then
			file = word
		end
	end
	if method == 'POST' and path == '/info' then
		req.setDataHandler(function(body)
			if not body then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
				return
			end
			local data = json.decode(body)
			if not data then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
			elseif Config.critError and not Config.apiKey then
				res.send(json.encode({
					['error'] = 'critical config error'
				}))
			elseif string.upper(data.password) ~= string.upper(Config.apiKey) then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
			else
				local pluginsFormatted = {}
				for name, plugin in pairs(Config.plugins) do
					local pl = plugin
					for k, v in pairs(pl) do
						if type(v) == 'function' then
							debugLog('replacing a function')
							pl[k] = 'function'
						end
					end
					table.insert(pluginsFormatted, name .. ': ' .. json.encode(pl))
				end
				res.send(json.encode({
					['status'] = 'ok',
					['cadInfo'] = string.gsub(dumpInfo(), '\n', '<br />'),
					['config'] = table.concat(pluginsFormatted, '<br /><br/>'),
					['console'] = string.gsub(GetConsoleBuffer(), '\n', '<br />'),
					['debug'] = string.gsub(table.concat(getDebugBuffer(), '\n'), '\n', '<br />')
				}))
			end
		end)
	elseif method == 'POST' and path == '/console' then
		req.setDataHandler(function(body)
			if not body then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
				return
			end
			local data = json.decode(body)
			if not data then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
			elseif Config.critError and not Config.apiKey then
				res.send(json.encode({
					['error'] = 'critical config error'
				}))
			elseif string.upper(data.password) ~= string.upper(Config.apiKey) then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
			else
				local s = string.gmatch(data.command, '%S+')()
				if s ~= 'sonoran' then
					res.send(json.encode({
						['error'] = 'not allowed'
					}))
					return
				end
				ExecuteCommand(data.command)
				res.send(json.encode({
					['status'] = 'ok',
					['output'] = string.gsub(GetConsoleBuffer(), '\n', '<br />')
				}))
			end
		end)
	elseif method == 'POST' and path == '/event' then
		req.setDataHandler(function(data)
			if not data then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
				return
			end
			local body = json.decode(data)
			if not body then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
				debugLog('Invalid event: ' .. tostring(body))
				return
			end
			if body.key and body.key:upper() == Config.apiKey:upper() then
				debugLog(('EVENT: %s - %s'):format(body.type, json.encode(body)))
				if Config.enablePushEventForwarding then
					PerformHttpRequest(Config.pushEventForwardUrl, function(statusCode, res, headers)
						debugLog('Forward Response: ' .. tostring(res))
					end, 'POST', data, {
						['Content-Type'] = 'application/json'
					})
				end
				if PushEventHandler[body.type:upper()] then
					CreateThread(function()
						body.res = res
						local success, result = PushEventHandler[body.type:upper()](body)
						if success then
							res.send('ok')
						else
							if not result then
								result = 'error'
							end
							res.send(result);
						end
					end)
				else
					TriggerEvent('SonoranCAD::pushevents:OtherEvent', body.type:upper(), body.data)
					res.send('ok - custom')
				end
			end
		end)
	elseif method == 'POST' and path == '/pluginevent' then
		req.setDataHandler(function(data)
			if not data then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
				return
			end
			local body = json.decode(data)
			if not body then
				res.send(json.encode({
					['error'] = 'bad request'
				}))
				return
			end
			if body.key and body.key:upper() == Config.apiKey:upper() then
				if not body.type or not PluginHttpHandlers[body.type] then
					return res.send('error')
				end
				local resp = PluginHttpHandlers[body.type](body)
				return res.send(json.encode(resp))
			else
				return res.send('error')
			end
		end)
	elseif method == 'GET' and PluginFilePaths[base] ~= nil then
		local data = LoadResourceFile(GetCurrentResourceName(), ('filestore/%s/%s'):format(base, file), 'r')
		if not data then
			warnLog('NOFILE: ' .. tostring(('%s/filestore/%s/%s'):format(GetResourcePath(GetCurrentResourceName()), base, file)))
			res.writeHead(404)
			res.send('404')
		else
			res.send(data)
		end
	elseif method == 'GET' and path:find('^/bodycam') then
		-- Extract the query string from the path
		local queryString = path:match('?.*$')
		local params = {}
		-- Parse the query string
		if queryString then
			for key, value in queryString:gmatch('([^&=?]-)=([^&=?]+)') do
				-- URL decode the value
				value = value:gsub('+', ' '):gsub('%%(%x%x)', function(h)
					return string.char(tonumber(h, 16))
				end)
				params[key] = value
			end
		end

		-- Extract the 'ident' and 'image' parameters
		local ident = params['ident']
		local image = params['image']
		-- Check if 'ident' and 'image' parameters exist and proceed with your logic
		if ident and image then
			local imagePath = GetResourcePath(GetCurrentResourceName()) .. '/screenshots/' .. ident .. '/' .. image
			-- Your logic here, for example, fetching and sending the image
			local imageFile = io.open(imagePath, 'rb')
			if not imageFile then
				res.send(json.encode({
					error = 'Image not found'
				}))
				return
			else
				local content = imageFile:read('*all')
				res.send(content)
			end
			-- Respond to the request with the bodycam image or relevant information
		else
			-- Handle the case where the required parameters are missing
			print('Missing \'ident\' or \'image\' parameter')
			-- Respond with an error or a message indicating the missing parameters
		end
	elseif path == '/' then
		local html = LoadResourceFile(GetCurrentResourceName(), '/core/html/index.html')
		res.send(html)
	else
		res.send('If you\'re seeing this, sonorancad is loaded.')
	end
end)

function AddPluginFilePath(path)
	if PluginFilePaths[path] == nil then
		PluginFilePaths[path] = true
		exports[GetCurrentResourceName()]:CreateFolderIfNotExisting(('%s/filestore/%s'):format(GetResourcePath(GetCurrentResourceName()), path))
	end
end

function SaveFileInPluginPath(path, filename, filedata)
	if PluginFilePaths[path] ~= nil then
		local file = assert(io.open(('%s/filestore/%s/%s'):format(GetResourcePath(GetCurrentResourceName()), path, filename), 'wb+'))
		file:write(filedata)
		file:close()
		debugLog('Saved file: ' .. ('%s/filestore/%s/%s'):format(GetResourcePath(GetCurrentResourceName()), path, filename))
	end
end

AddEventHandler('SonoranCAD::pushevents:shim', function(chunk)
	local body = json.decode(chunk)
	if not body then
		debugLog('Invalid event: ' .. tostring(chunk))
		return
	end
	if body.key and body.key:upper() == Config.apiKey:upper() then
		if PushEventHandler[body.type:upper()] then
			CreateThread(function()
				body.res = res
				local success, result = PushEventHandler[body.type:upper()](body)
			end)
		end
	end
end)

AddPluginFilePath('images', function(path)

end)
