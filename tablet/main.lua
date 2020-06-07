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


function Gui(toggle)
	SetNuiFocus(toggle, toggle)
	guiEnabled = toggle

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
end)