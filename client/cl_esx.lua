--[[
        SonoranCAD FiveM - A SonoranCAD integration for FiveM servers
              Copyright (C) 2020  Sonoran Software Systems LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program in the file "LICENSE".  If not, see <http://www.gnu.org/licenses/>.
]]

---------------------------------------------------------------------------
-- ESX Integration Initialization/Events/Functions
---------------------------------------------------------------------------
PlayerData = {}
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
	end

	while ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end

  	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
  print(ESX.DumpTable(PlayerData))
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

function getJob()
  if PlayerData.job ~= nil then
  return PlayerData.job.name
  end
end

local recievedIdentity = false
returnedIdentity = nil
RegisterNetEvent('sonorancad:returnIdentity')
AddEventHandler('sonorancad:returnIdentity', function(data)
    returnedIdentity = data
    recievedIdentity = true
end)

function GetIdentity(callback, target)
    recievedIdentity = false
    returnIdentity = false
    TriggerServerEvent("sonorancad:getIdentity", target)
    local timeStamp = GetGameTimer()
    while not recievedIdentity do
        if GetGameTimer() > timeStamp then
            callback(nil)
        end
        --print('waiting for callback')
        Citizen.Wait(0)
    end
    callback(recievedIdentity)
end

RegisterNetEvent('sonorancad:characterUpdated')
AddEventHandler('sonorancad:characterUpdated', function(data)
    -- Fired when ESX_Identity changes character, should recheck job and char info
    
end)

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

RegisterCommand('test', function()
    PlayerData = ESX.GetPlayerData()
    PlayerData.inventory = nil
    print(dump(PlayerData))
end)
