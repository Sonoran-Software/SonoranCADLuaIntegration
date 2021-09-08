nuiFocused = false
isRegistered = false
playerHolding = ''

-- Debugging Information
isDebugging = false

function DebugMessage(message, module)
	if module ~= nil then message = "[" .. module .. "] " .. message end
	print(message .. "\n")
end

-- Initialization Procedure
Citizen.CreateThread(function()
	Wait(1000)

	-- Set Default Module Sizes
	InitModuleSize("cad")
	InitModuleSize("hud")

	SetModuleUrl("cad", CONFIG.cadUrl)

	-- Disable Controls Loop
	while true do
		if nuiFocused then	-- Disable controls while NUI is focused.
			DisableControlAction(0, 1, nuiFocused) -- LookLeftRight
			DisableControlAction(0, 2, nuiFocused) -- LookUpDown
			DisableControlAction(0, 142, nuiFocused) -- MeleeAttackAlternate
			DisableControlAction(0, 106, nuiFocused) -- VehicleMouseControlOverride
		end
		Citizen.Wait(0) -- Yield until next frame.
	end
end)

function InitModuleSize(module)
	-- Check if the size of the specified module is already configured.
	local moduleWidth = GetResourceKvpString(module .. "width")
	local moduleHeight = GetResourceKvpString(module .. "height")
	if moduleWidth ~= nil and moduleHeight ~= nil then
		DebugMessage("retrieving saved presets", module)
		-- Send message to NUI to resize the specified module.
		SetModuleSize(module, moduleWidth, moduleHeight)
		SendNUIMessage({
			type = "refresh",
			module = module
		})
	end
end

-- Set a Module's Size
function SetModuleSize(module, width, height)
	-- Send message to NUI to resize the specified module.
	DebugMessage("sending resize message to nui", module)
	SendNUIMessage({
		type = "resize",
		module = module,
		newWidth = width,
		newHeight = height
	})

	DebugMessage("saving module size to kvp", module)
	SetResourceKvp(module .. "width", newWidth)
	SetResourceKvp(module .. "height", newHeight)
end

-- Refresh a Module
function RefreshModule(module)
	DebugMessage("sending refresh message to nui", module)
	SendNUIMessage({
		type = "refresh",
		module = module
	})
end

-- Display a Module
function DisplayModule(module, show)
	DebugMessage("sending display message to nui", module)
	if not isRegistered then apiCheck = true end
	SendNUIMessage({
		type = "display",
		module = module,
		apiCheck = apiCheck,
		enabled = show
	})
	-- Eventually break this into individual module parameters.
	if module == "cad" then
		SetTablet(show)
	end
end

-- Set Module URL (for iframes)
function SetModuleUrl(module, url)
	DebugMessage("sending url update message to nui", module)
	SendNUIMessage({
		type = "setUrl",
		url = url,
		module = module
	})
end

-- Print a chat message to the current player
function PrintChatMessage(text)
	TriggerEvent('chatMessage', "system", { 255, 0, 0 }, text)
end

-- Set the focus state of the NUI
function SetFocused(focused)
	nuiFocused = focused
	SetNuiFocus(nuiFocused, nuiFocused)
end

-- Remove NUI focus
RegisterNUICallback('NUIFocusOff', function()
	DisplayModule("cad", false)
	SetFocused(false)
end)

-- CAD Module Commands
RegisterCommand("showcad", function(source, args, rawCommand)
	DisplayModule("cad", true)
	SetFocused(true)
end, false)
RegisterKeyMapping('showcad', 'CAD Tablet', 'keyboard', '')

TriggerEvent('chat:addSuggestion', '/cadsize', "Resize CAD to specific width and height in pixels. Default is 1100x510", {
	{ name="Width", help="Width in pixels" }, { name="Height", help="Height in pixels" }
})
RegisterCommand("cadsize", function(source,args,rawCommand)
	if not args[1] and not args[2] then return end
	SetModuleSize("cad", args[1], args[2])
end)
RegisterCommand("cadrefresh", function()
	RefreshModule("cad")
end)

RegisterCommand("checkapiid", function(source,args,rawCommand)
	TriggerServerEvent("sonoran:tablet:forceCheckApiId")
end, false)

-- This function will eventually be expanded to multiple items.
function SetTablet(using)
	if using then
		-- Take out the tablet.
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
		-- Put the tablet away.
		DetachEntity(tabletProp, true, true)
		DeleteObject(tabletProp)
		TaskPlayAnim(GetPlayerPed(-1), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "exit", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
	end
end

AddEventHandler('onClientResourceStart', function(resourceName) --When resource starts, stop the GUI showing. 
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end
	setnu
	
	TriggerServerEvent("sonoran:tablet:forceCheckApiId")
end)

RegisterNetEvent("sonoran:tablet:apiIdNotFound")
AddEventHandler('sonoran:tablet:apiIdNotFound', function()
	SendNUIMessage({
		type = "regbar"
	})
end)

RegisterNetEvent("sonoran:tablet:apiIdFound")
AddEventHandler("sonoran:tablet:apiIdFound", function()
	isRegistered = true
end)

RegisterNUICallback('SetAPIData', function(data,cb)
	TriggerServerEvent("sonoran:tablet:setApiId", data.session, data.username)
	TriggerServerEvent("sonoran:tablet:forceCheckApiId")
	cb(true)
end)

RegisterNUICallback('runApiCheck', function()
	TriggerServerEvent("sonoran:tablet:forceCheckApiId")
end)

RegisterNetEvent("sonoran:tablet:failed")
AddEventHandler("sonoran:tablet:failed", function(message)
	errorLog("Failed to set API ID: "..tostring(message))
end)