--[[
    Sonaran CAD Plugins

    Plugin Name: frameworksupport
    Creator: Sonoran Software Systems LLC
    Description: Enable using ESX (or ESX clones) character information in Sonoran integration plugins
]] CreateThread(function()
	Config.LoadPlugin('frameworksupport', function(pluginConfig)

		if pluginConfig.enabled then
			local QBCore = nil
            local ESX = nil
			if pluginConfig.usingQBCore then
				QBCore = exports['qb-core']:GetCoreObject()
			end
			if not pluginConfig.usingQBCore then
				ESX = exports['es_extended']:getSharedObject()
			end
			JobCache = {}

			RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
			AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
				playerName = QBCore.Functions.GetPlayerData()
			end)

			-- Legacy ESX helper functions to get Character Info using MySQL-Async
			local function safeParameters(params)
				if nil == params then
					return {[''] = ''}
				end

				assert(type(params) == 'table', 'A table is expected')
				assert(params[1] == nil, 'Parameters should not be an array, but a map (key / value pair) instead')

				if next(params) == nil then
					return {[''] = ''}
				end

				return params
			end

			function MysqlAsyncFetchAll(query, params, func)
				assert(type(query) == 'string', 'The SQL Query must be a string')

				exports['mysql-async']:mysql_fetch_all(query, safeParameters(params), func)
			end

			function MysqlSyncFetchAll(query, params)
				assert(type(query) == 'string', 'The SQL Query must be a string')

				local res = {}
				local finishedQuery = false
				exports['mysql-async']:mysql_fetch_all(query, safeParameters(params), function(result)
					res = result
					finishedQuery = true
				end)
				repeat
					Wait(0)
				until finishedQuery == true
				return res
			end

			function GetLegacyCharInfo(target, callback)
				local identifier = GetPlayerIdentifiers(target)[1]
				local result = MysqlSyncFetchAll('SELECT * FROM `users` WHERE `identifier` = @identifier', {['@identifier'] = identifier})
				if result[1]['firstname'] ~= nil then
					local data = {identifier = result[1]['identifier'], firstname = result[1]['firstname'], lastname = result[1]['lastname'], dateofbirth = result[1]['dateofbirth'], sex = result[1]['sex'],
						height = result[1]['height']}
					callback(data)
				else
					local data = {identifier = identifier, firstname = '', lastname = '', dateofbirth = '', sex = '', height = ''}
					callback(data)
				end
			end

			-- Helper function to get the ESX Identity object from your database/framework
			function GetIdentity(target, cb)
				local xPlayer = nil
				if pluginConfig.usingQBCore then
					xPlayer = QBCore.Functions.GetPlayer(target)
				else
					xPlayer = ESX.GetPlayerFromId(target)
				end
				if xPlayer ~= nil then
					debugLog('GetIdentity OK')
					if pluginConfig.usingQBCore then
						xPlayer.firstName = xPlayer.PlayerData.charinfo.firstname
						xPlayer.lastName = xPlayer.PlayerData.charinfo.lastname
						xPlayer.name = xPlayer.firstName .. ' ' .. xPlayer.lastName
					elseif pluginConfig.legacyESX then
						-- Get Char info from Database using MySQL-Async
						GetLegacyCharInfo(target, function(data)
							-- debug logging for lookups that find no user data in database
							if data.firstname == '' then
								debugLog('Legacy ESX database lookup found no user data for identifier: ' .. tostring(data.identifier))
							end
							-- Set quick reference variables
							xPlayer.firstname = data.firstname
							xPlayer.lastName = data.lastname
							xPlayer.name = data.firstname .. ' ' .. data.lastname
							-- Adjust xPlayer.getName()
							xPlayer.getName = function()
								return xPlayer.name
							end
						end)
					end
					if cb ~= nil then
						debugLog('Running callback')
						cb(xPlayer)
					else
						debugLog('Running client event')
						TriggerClientEvent('SonoranCAD::frameworksupport:returnIdentity', target, xPlayer)
					end
				else
					debugLog('GetIdentity Failed')
					if cb ~= nil then
						cb({})
					else
						TriggerClientEvent('SonoranCAD::frameworksupport:returnIdentity', target, {})
					end
				end
			end

			-- Helper function that just returns the current job as a callback
			function GetCurrentJob(player, cb)
				local currentJob = ''
				if cb == nil then
					if JobCache[tostring(player)] ~= nil then
						debugLog('Return cached player')
						return JobCache[tostring(player)]
					else
						debugLog(('Player %s has no cached job'):format(player))
					end
				end
				local xPlayer = nil
				if pluginConfig.usingQBCore then
					xPlayer = QBCore.Functions.GetPlayer(tonumber(player))
				else
					xPlayer = ESX.GetPlayerFromId(player)
				end
				if xPlayer == nil then
					warnLog(('Failed to obtain player info from %s. ESX.GetPlayerFromId returned nil.'):format(player))
				else
					if pluginConfig.usingQBCore then
						if not xPlayer.PlayerData.job.onduty then -- QBUS job.onduty is false when on duty??? okayyyyy
							currentJob = xPlayer.PlayerData.job.name
						else
							currentJob = 'offduty' .. xPlayer.PlayerData.job.name
						end
					else
						currentJob = xPlayer.job.name
					end
					debugLog('Returned job: ' .. tostring(currentJob))
				end
				if cb == nil then
					JobCache[tostring(player)] = currentJob
					return currentJob
				elseif cb == true then
					JobCache[tostring(player)] = currentJob
					debugLog('refreshed job cache for player ' .. player .. '-' .. currentJob)
				else
					cb(currentJob)
				end
			end

			-- Caching functionality, used locally to reduce database load
			CreateThread(function()
				while ESX == nil do
					Wait(10)
				end
				local xPlayers = nil
				if pluginConfig.usingQBCore then
					xPlayers = QBCore.Functions.GetPlayers()
				else
					xPlayers = ESX.GetPlayers()
				end
				for i = 1, #xPlayers, 1 do
					local player = nil
					if pluginConfig.usingQBCore then
						player = QBCore.Functions.GetPlayers(tonumber(xPlayers[i]))
					else
						player = ESX.GetPlayerFromId(xPlayers[i])
					end
					if player == nil then
						debugLog('Failed to obtain job from player ' .. tostring(xPlayers[i]))
					else
						if pluginConfig.usingQBCore then
							if not player.PlayerData.job.onduty then
								JobCache[tostring(player)] = player.PlayerData.job.name
							else
								JobCache[tostring(player)] = 'offduty' .. player.PlayerData.job.name
							end
						else
							JobCache[tostring(player)] = player.job.name
						end
					end
				end
				Wait(30000)
			end)

			AddEventHandler('playerDropped', function()
				JobCache[tostring(source)] = nil
			end)

			-- Event for clients to request esx_identity information from the server
			RegisterNetEvent('SonoranCAD::frameworksupport:getIdentity')
			AddEventHandler('SonoranCAD::frameworksupport:getIdentity', function()
				GetIdentity(source)
			end)

			-- Event for clients to trigger job refresh on server (primarily for QBUS onduty handling)
			RegisterNetEvent('SonoranCAD::frameworksupport:refreshJobCache')
			AddEventHandler('SonoranCAD::frameworksupport:refreshJobCache', function()
				local src = source
				GetCurrentJob(src, true)
			end)

			-- EVENT_RECORD_ADDED
			RegisterServerEvent('SonoranCAD::pushevents:RecordAdded')
			AddEventHandler('SonoranCAD::pushevents:RecordAdded', function(record)
				-- Check to see if we should be issuing fines.
				if not pluginConfig.issueFines then
					return
				end
				debugLog('Receieved new record')

				local isFineable = false
				for _, formName in pairs(pluginConfig.fineableForms) do
					if record.name:upper() == formName:upper() then
						isFineable = true
					end
				end
				if isFineable then
					-- Create empty citation object
					local citation = {issuer = nil, -- Issuer of the fine
					first = nil, -- First name of the fine target
					last = nil, -- Last name of the fine target
					fine = 0, -- Total sum of all fineable offenses
					department = nil}
					debugLog(record.name:upper() .. ' is a fineable record.')
					-- Iterate the sections of the record
					for k, sec in pairs(record.sections) do
						-- Iterate the fields of the record section
						for _, field in pairs(sec.fields) do
							-- Store the first name of the fine target
							if field.uid == 'first' then
								citation.first = field.value
							end
							-- Store the last name of the fine target
							if field.uid == 'last' then
								citation.last = field.value
							end
							-- Retrieve the new Unit Name from the Agency Information
							if field.type == 'UNIT_NAME' then
								citation.issuer = field.value
							end
							-- Get "Special" fields from the report
							if field.type == 'UNIT_DEPARTMENT' then
								citation.department = field.value
							end
							if field.label == 'New Field Name' then
								if field.data then
									-- Get and store the name of the issuing officer to the citation
									if field.data.officer then
										citation.issuer = field.data.officer
									end
									-- Get and add speeding charges to the citation
									if field.data.fine then
										citation.fine = citation.fine + tonumber(field.data.fine)
										debugLog('Added fine of $' .. field.data.fine .. ' for ' .. field.data.vehicleSpeed .. ' in a ' .. field.data.speedLimit .. 'zone.')
									end
									-- Get and add other charges to the citation
									if field.data.charges then
										for _, charge in pairs(field.data.charges) do
											local fineTotal = tonumber(charge.arrestBondAmount) * charge.arrestChargeCounts
											citation.fine = citation.fine + tonumber(fineTotal)
											debugLog('Added fine of $' .. fineTotal .. ' for ' .. charge.arrestChargeCounts .. ' counts of ' .. charge.arrestCharge)
										end
									end
								end
							end
						end
					end

					debugLog('New Citation to Issue:')
					debugLog('Issuer: ' .. tostring(citation.issuer))
					debugLog('Issued To: ' .. tostring(citation.first) .. ' ' .. tostring(citation.last))
					debugLog('Total Fines: $' .. tostring(citation.fine))

					-- If the citation is missing a first name or a last name we can't issue the fine.
					if citation.first == '' or citation.last == '' then
						return
					end

					-- Find the civilian that matches the citation and issue them a fine.
					if pluginConfig.usingQBCore then
						xPlayers = QBCore.Functions.GetPlayers()
					else
						xPlayers = ESX.GetPlayers()
					end

					for i = 1, #xPlayers, 1 do
						GetIdentity(xPlayers[i], function(xPlayer)
							if pluginConfig.usingQBCore then
								if xPlayer.PlayerData.charinfo.firstname == citation.first then
									if xPlayer.PlayerData.charinfo.lastname == citation.last then
										debugLog('found player online matching fined character')
										xPlayer.Functions.RemoveMoney('bank', citation.fine)
										if pluginConfig.usingQBManagement then
											if pluginConfig.qbManagementAccountNames[citation.department] ~= nil then
												exports['qb-management']:AddMoney(pluginConfig.qbManagementAccountNames[citation.department], citation.fine)
											end
										end
										if pluginConfig.fineNotify then
											debugLog('sending fine notification')
											local finemessage = citation.first .. ' ' .. citation.last .. ' has been issued a fine of $' .. citation.fine
											if citation.issuer ~= '' then
												finemessage = finemessage .. ' by ' .. citation.issuer
											end
											TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, multiline = true, args = {finemessage}})
										end
										if pluginConfig.qbNotifyFinedPlayer then
											TriggerClientEvent('QBCore:Notify', xPlayer.PlayerData.source, pluginConfig.qbFineMessage:gsub('$AMOUNT', citation.fine):gsub('$OFFICER_NAME', citation.issuer), 'error', 5000)
										end
									end
								end
							else
								if xPlayer.getName() == citation.first .. ' ' .. citation.last then
									debugLog('found player online matching fined character')
									xPlayer.removeAccountMoney('bank', citation.fine)
									ESX.SavePlayer(xPlayer)
									if pluginConfig.fineNotify then
										debugLog('sending fine notification')
										local finemessage = xPlayer.getName() .. ' has been issued a fine of $' .. citation.fine
										if citation.issuer ~= '' then
											finemessage = finemessage .. ' by ' .. citation.issuer
										end
										TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, multiline = true, args = {finemessage}})
									end
								end
							end
						end)
					end
				end
			end)
		end

	end)
end)
