guiEnabled = false
Citizen.CreateThread(function()
  while true do
      if guiEnabled then
          DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
          DisableControlAction(0, 2, guiEnabled) -- LookUpDown

          DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate

          DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride

      end
      Citizen.Wait(0) --MH LUA
  end
end)

function PrintChatMessage(text)
  TriggerEvent('chatMessage', "system", { 255, 0, 0 }, text)
end
  
RegisterNUICallback('NUIFocusOff', function()
  Gui(false)
end)

RegisterCommand("showcad", function(source, args, rawCommand)
	Gui(not guiEnabled)
end, false)

RegisterCommand("test", function(source,args,rawCommand)
	TriggerServerEvent("sonoran:tablet:forceCheckApiId")
end, false)


function Gui(toggle)
  SetNuiFocus(toggle, toggle)
  guiEnabled = toggle

  if guiEnabled then
      RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@base")
      while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base") do
          Citizen.Wait(0)
      end
      local tabletModel = GetHashKey("prop_cs_tablet")
      local bone = GetPedBoneIndex(GetPlayerPed(-1), 60309)
      RequestModel(tabletModel)
      while not HasModelLoaded(tabletModel) do
          Citizen.Wait(100)
      end
      tabletProp = CreateObject(tabletModel, 1.0, 1.0, 1.0, 1, 1, 0)
      AttachEntityToEntity(tabletProp, GetPlayerPed(-1), bone, 0.03, 0.002, -0.0, 10.0, 160.0, 0.0, 1, 0, 0, 0, 2, 1)
      TaskPlayAnim(GetPlayerPed(-1), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
  else
      DetachEntity(tabletProp, true, true)
      DeleteObject(tabletProp)
      TaskPlayAnim(GetPlayerPed(-1), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "exit", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
  end

  SendNUIMessage({
      type = "enableui",
      enable = toggle
  })
end

AddEventHandler('onClientResourceStart', function(resourceName) --When resource starts, stop the GUI showing. 
    if(GetCurrentResourceName() ~= resourceName) then
      return
    end
    Gui(false)
	
	TriggerServerEvent("sonoran:tablet:forceCheckApiId")
	
end)

RegisterNetEvent("sonoran:tablet:apiIdNotFound")
AddEventHandler('sonoran:tablet:apiIdNotFound', function()

	SetNuiFocus(true, true)

	SendNUIMessage({
      type = "enableui",
      enable = true,
	  apiCheck = true
	})

end)

RegisterNUICallback('SetAPIData', function(data,cb)
	
	TriggerServerEvent("sonoran:tablet:setApiId", data.session, data.username)
	
	cb(true)
end)