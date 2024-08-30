nuiFocused = false
isRegistered = false
usingTablet = false
myident = nil
isMiniVisible = false

-- Debugging Information
isDebugging = true

function DebugMessage(message, module)
	if not isDebugging then return end
	if module ~= nil then message = "[" .. module .. "] " .. message end
	print(message .. "\n")
end

-- Initialization Procedure
Citizen.CreateThread(function()
	Wait(1000)
	-- Set Default Module Sizes
	InitModuleSize("cad")
	InitModuleSize("hud")
	InitModuleConfig("hud")
	local convar = GetConvar("sonorantablet_cadUrl", 'https://sonorancad.com/')
	local comId = convar:match("comid=(%w+)")
	if comId ~= "" then
		SetModuleUrl("cad", GetConvar("sonorantablet_cadUrl", 'https://sonorancad.com/login?comid='..comId), true)
	else
		SetModuleUrl("cad", GetConvar("sonorantablet_cadUrl", 'https://sonorancad.com/'), false)
	end

	TriggerServerEvent("SonoranCAD::mini:CallSync_S")

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

function InitModuleConfig(module)
	local moduleMaxRows = GetResourceKvpString(module .. "maxrows")
	if moduleMaxRows ~= nil then
		DebugMessage("retrieving config presets", module)
		-- Send messsage to NUI to update config of specified module.
		SetModuleConfigValue(module, "maxrows", moduleMaxRows)
		SendNUIMessage({
			type = "refresh",
			module = module
		})
	end
end

function SetModuleConfigValue(module, key, value)
	DebugMessage(("MODULE %s Setting %s to %s"):format(module, key, value))
	SendNUIMessage({
		type = "config",
		module = module,
		key = key,
		value = value
	})
	DebugMessage("saving config value to kvp")
	SetResourceKvp(module .. key, value)
end

-- Set a Module's Size
function SetModuleSize(module, width, height)
	DebugMessage(("MODULE %s SIZE %s - %s"):format(module, width, height))
	-- Send message to NUI to resize the specified module.
	DebugMessage("sending resize message to nui", module)
	SendNUIMessage({
		type = "resize",
		module = module,
		newWidth = width,
		newHeight = height
	})

	DebugMessage("saving module size to kvp")
	SetResourceKvp(module .. "width", width)
	SetResourceKvp(module .. "height", height)
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
	DebugMessage("sending display message to nui "..tostring(show), module)
	if not isRegistered then apiCheck = true end
	SendNUIMessage({
		type = "display",
		module = module,
		apiCheck = apiCheck,
		enabled = show
	})
	if module == "hud" then
		isMiniVisible = show
	end
end

-- Set Module URL (for iframes)
function SetModuleUrl(module, url, hasComID)
	DebugMessage("sending url update message to nui", module)
	SendNUIMessage({
		type = "setUrl",
		url = url,
		module = module,
		comId = hasComID
	})
end

-- Print a chat message to the current player
function PrintChatMessage(text)
	TriggerEvent('chatMessage', "System", { 255, 0, 0 }, text)
end

-- Set the focus state of the NUI
function SetFocused(focused)
	nuiFocused = focused
	SetNuiFocus(nuiFocused, nuiFocused)
end

-- Remove NUI focus
RegisterNUICallback('NUIFocusOff', function()
	DisplayModule("cad", false)
	SetTablet(false)
	SetFocused(false)
end)

RegisterNetEvent("SonoranCAD::mini:OpenMini:Return")
AddEventHandler('SonoranCAD::mini:OpenMini:Return', function(authorized, ident)
	myident = ident
	if authorized then
		DisplayModule("hud", true)
		if not GetResourceKvpString("shownTutorial") then
			ShowHelpMessage()
			SetResourceKvp("shownTutorial", "yes")
		end
	else
		PrintChatMessage("You are not logged into the CAD or your API id is not set.")
	end
end)

CreateThread(function()
	while true do
		if isMiniVisible then
			TriggerServerEvent("SonoranCAD::mini:CallSync_S")
		end
		Wait(10000)
	end
end)

function ShowHelpMessage()
	PrintChatMessage("Keybinds: Attach/Detach [K], Details [L], Previous/Next [LEFT/RIGHT], changable in settings!")
end

-- Mini Module Commands
RegisterCommand("minicad", function(source, args, rawCommand)
	TriggerServerEvent("SonoranCAD::mini:OpenMini")
end, false)
RegisterKeyMapping('minicad', 'Mini CAD', 'keyboard', '')

RegisterCommand("minicadhelp", function() ShowHelpMessage() end)

RegisterCommand("minicadp", function(source, args, rawCommand)
	if not isMiniVisible then return end
	SendNUIMessage({ type = "command", key="prev" })
end, false)
RegisterKeyMapping('minicadp', 'Previous Call', 'keyboard', 'LEFT')

RegisterCommand("minicada", function(source, args, rawCommand)
	print("ismini "..tostring(isMiniVisible))
	if not isMiniVisible then return end
	SendNUIMessage({ type = "command", key="attach" })
end, false)
RegisterKeyMapping('minicada', 'Attach to Call', 'keyboard', 'K')

RegisterCommand("minicadd", function(source, args, rawCommand)
	if not isMiniVisible then return end
	SendNUIMessage({ type = "command", key="detail" })
end, false)
RegisterKeyMapping('minicadd', 'Call Detail', 'keyboard', 'L')

RegisterCommand("minicadn", function(source, args, rawCommand)
	if not isMiniVisible then return end
	SendNUIMessage({ type = "command", key="next" })
end, false)
RegisterKeyMapping('minicadn', 'Next Call', 'keyboard', 'RIGHT')

TriggerEvent('chat:addSuggestion', '/minicadsize', "Resize the Mini-CAD to specific width and height in pixels.", {
	{ name="Width", help="Width in pixels" }, { name="Height", help="Height in pixels" }
})
RegisterCommand("minicadsize", function(source,args,rawCommand)
	if not args[1] and not args[2] then return end
	SetModuleSize("hud", args[1], args[2])
end)
RegisterCommand("minicadrefresh", function()
	RefreshModule("hud")
end)

RegisterCommand("minicadrows", function(source, args, rawCommand)
	if #args ~= 1 then
		PrintChatMessage("Please specify a number of rows to display.")
		return
	else
		SetModuleConfigValue("hud", "maxrows", tonumber(args[1]) - 1)
		PrintChatMessage("Maximum Mini-CAD call notes set to " .. args[1])
	end
end)
TriggerEvent('chat:addSuggestion', '/minicadrows', "Specify max number of call notes on Mini-CAD.", {
	{ name="rows", help="any number (default 10)" }
})

-- CAD Module Commands
RegisterCommand("showcad", function(source, args, rawCommand)
	DisplayModule("cad", true)
	SetTablet(true)
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

-- Mini-Cad Callbacks
RegisterNUICallback('AttachToCall', function(data, cb)
	--Debug Only
	--print("cl_main -> sv_main: SonoranCAD::mini:AttachToCall")
	TriggerServerEvent("SonoranCAD::mini:AttachToCall", data.callId)
	cb({ ok = true })
end)

-- Mini-Cad Callbacks
RegisterNUICallback('DetachFromCall', function(data, cb)
	--Debug Only
	--print("cl_main -> sv_main: SonoranCAD::mini:DetachFromCall")
	TriggerServerEvent("SonoranCAD::mini:DetachFromCall", data.callId)
	cb({ ok = true })
end)

RegisterNUICallback("ShowHelp", function() ShowHelpMessage() end)

RegisterNUICallback("VisibleEvent", function(data, cb)
	if data.module == "hud" then
		isMiniVisible = data.state
	end
	cb({ ok = true })
end)

-- Mini-Cad Events
RegisterNetEvent("SonoranCAD::mini:CallSync")
AddEventHandler("SonoranCAD::mini:CallSync", function(CallCache, EmergencyCache)
	--Debug Only
	--print("sv_main -> cl_main: SonoranCAD::mini:CallSync")
	--print(json.encode(CallCache))
	SendNUIMessage({
		type = 'callSync',
		ident = myident,
		activeCalls = CallCache,
		emergencyCalls = EmergencyCache
	})
end)

AddEventHandler('onClientResourceStart', function(resourceName) --When resource starts, stop the GUI showing.
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end
	SetFocused(false)
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