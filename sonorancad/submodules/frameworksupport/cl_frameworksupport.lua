--[[
    Sonaran CAD Plugins

    Plugin Name: frameworksupport
    Creator: Sonoran Software Systems LLC
    Description: Enable using ESX or QBCore character information in Sonoran integration plugins
]] CreateThread(function()
	Config.LoadPlugin('frameworksupport', function(pluginConfig)

		if pluginConfig.enabled then
			CreateThread(function()
				local QBCore = nil
				if pluginConfig.usingQBCore then
					QBCore = exports['qb-core']:GetCoreObject()
				end
				PlayerData = {}
				local ESX = nil

				CreateThread(function()
					if not pluginConfig.usingQBCore then
						ESX = exports['es_extended']:getSharedObject()
					end
					if pluginConfig.usingQBCore then
						while QBCore.Functions.GetPlayerData() == nil do
							Wait(10)
						end
						PlayerData = QBCore.Functions.GetPlayerData()
					else
						while ESX.GetPlayerData() == nil do
							Wait(10)
						end
						PlayerData = ESX.GetPlayerData()
					end
				end)

				-- Listen for when new players load into the game
				RegisterNetEvent('esx:playerLoaded')
				AddEventHandler('esx:playerLoaded', function(xPlayer)
					if pluginConfig.usingQBCore then
						PlayerData = QBCore.Functions.GetPlayerData()
					else
						PlayerData = xPlayer
					end
				end)
				-- Listen for when jobs are changed in esx_jobs
				if pluginConfig.usingQBCore then
					RegisterNetEvent('QBCore:Client:OnJobUpdate')
					AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
						PlayerData.job = job
						if PlayerData.job.onduty == true then
							PlayerData.job.name = 'offduty' .. PlayerData.job.name
						end
						TriggerServerEvent('SonoranCAD::frameworksupport:refreshJobCache')
						TriggerEvent('SonoranCAD::frameworksupport:JobUpdate', job)
					end)
				else
					RegisterNetEvent('esx:setJob')
					AddEventHandler('esx:setJob', function(job)
						PlayerData.job = job
						TriggerServerEvent('SonoranCAD::frameworksupport:refreshJobCache')
						TriggerEvent('SonoranCAD::frameworksupport:JobUpdate', job)
					end)
				end
				-- QBUS onduty change (ESX typically uses jobs to change duty instead)
				if pluginConfig.usingQBCore then
					RegisterNetEvent('QBCore:Client:SetDuty')
					AddEventHandler('QBCore:Client:SetDuty', function(onduty)
						local job = PlayerData.job
						if onduty then
							job.name = string.gsub(job.name, 'offduty', '')
						else
							job.name = 'offduty' .. job.name
						end
						PlayerData.job = job
						TriggerServerEvent('SonoranCAD::frameworksupport:refreshJobCache')
						TriggerEvent('SonoranCAD::frameworksupport:JobUpdate', job)
					end)
				end

				-- Function to return esx_identity data on the client from server
				-- This event listens for data from the server when requested
				local recievedIdentity = false
				returnedIdentity = nil
				RegisterNetEvent('SonoranCAD::frameworksupport:returnIdentity')
				AddEventHandler('SonoranCAD::frameworksupport:returnIdentity', function(data)
					recievedIdentity = true
					if data.job == nil then
						warnLog('Warning: no identity data was found.')
					else
						returnedIdentity = data
					end
				end)
				-- This function requests data from the server
				function GetIdentity(callback)
					recievedIdentity = false
					returnIdentity = false
					TriggerServerEvent('SonoranCAD::frameworksupport:getIdentity')
					local timeStamp = GetGameTimer()
					while not recievedIdentity do
						Wait(0)
					end
					callback(returnedIdentity)
				end

			end)
		end
	end)
end)
