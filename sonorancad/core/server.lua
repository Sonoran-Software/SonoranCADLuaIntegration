Plugins = {}

ApiUrls = {
    production = "https://api.sonorancad.com/",
    development = "https://cadapi.dev.sonoransoftware.com/"
}

function getApiUrl()
    if Config.mode == nil then
        return ApiUrls.production
    else
        if ApiUrls[Config.mode] ~= nil then
            return ApiUrls[Config.mode]
        else
            Config.critError = true
            assert(false, "Invalid mode. Valid values are production, development")
        end
    end
end

CreateThread(function()
    infoLog("Starting SonoranCAD from "..GetResourcePath("sonorancad"))
    Config.apiUrl = getApiUrl()
    exports['sonorancad']:clearScreenshotsFolder()
    performApiRequest({}, "GET_VERSION", function(result, ok)
        if not ok then
            logError("API_ERROR")
            Config.critError = true
            return
        end
        Config.apiVersion = tonumber(string.sub(result, 1, 1))
        if Config.apiVersion < 2 then
            logError("API_PAID_ONLY")
            Config.critError = true
        end
        debugLog(("Set version %s from response %s"):format(Config.apiVersion, result))
        infoLog(("Loaded community ID %s with API URL: %s"):format(Config.communityID, Config.apiUrl))
    end)
    if Config.primaryIdentifier == "steam" and (GetConvar("steam_webapiKey", "none") == "none" or GetConvar("steam_webapiKey", "none") == "") then
        logError("STEAM_ERROR")
        Config.critError = true
    end
    local versionfile = json.decode(LoadResourceFile(GetCurrentResourceName(), "/version.json"))
    local fxversion = versionfile.testedFxServerVersion
    local currentFxVersion = getServerVersion()
    if currentFxVersion ~= nil and fxversion ~= nil then
        if tonumber(currentFxVersion) < tonumber(fxversion) then
            warnLog(("SonoranCAD has been tested with FXServer version %s, but you're running %s. Please update ASAP."):format(fxversion, currentFxVersion))
        end
    end
    if GetResourceState("sonoran_updatehelper") == "started" then
        ExecuteCommand("stop sonoran_updatehelper")
    end
    manuallySetUnitCache() -- set unit cache on startup
end)

exports("getCadVersion", function()
    return Config.apiVersion
end)

-- Toggles API sender.
RegisterServerEvent("cadToggleApi")
AddEventHandler("cadToggleApi", function()
    Config.apiSendEnabled = not Config.apiSendEnabled
end)

--[[
    Sonoran CAD API Handler - Core Wrapper
]]

ApiEndpoints = {
    ["UNIT_LOCATION"] = "emergency",
    ["CALL_911"] = "emergency",
    ["UNIT_PANIC"] = "emergency",
    ["GET_VERSION"] = "general",
    ["GET_SERVERS"] = "general",
    ["ATTACH_UNIT"] = "emergency",
    ["DETACH_UNIT"] = "emergency",
    ["ADD_CALL_NOTE"] = "emergency",
    ["RECORD_ADD"] = "general",
    ["RECORD_UPDATE"] = "general",
    ["SET_SERVERS"] = "general",
    ["GET_CHARACTERS"] = "civilian",
	["EDIT_CHARACTER"] = "civilian",
	["NEW_RECORD"] = "general",
	["EDIT_RECORD"] = "general",
	["REMOVE_RECORD"] = "general",
	["GET_TEMPLATES"] = "general",
	["LOOKUP_INT"] = "general",
}

EndpointsRequireId = {
    ["UNIT_STATUS"] = true,
    ["KICK_UNIT"] = true,
    ["UNIT_PANIC"] = true,
    ["UNIT_LOCATION"] = true,
    ["NEW_CHARACTER"] = true,
    ["REMOVE_CHARACTER"] = true,
    ["EDIT_CHARACTER"] = true,
    ["GET_CHARACTERS"] = true,
    ["CHECK_APIID"] = true,
    ["APPLY_PERMISSION_KEY"] = true,
    ["BAN_USER"] = true,
    ["KICK_USER"] = true
}



function registerApiType(type, endpoint)
    ApiEndpoints[type] = endpoint
end
exports("registerApiType", registerApiType)

local rateLimitedEndpoints = {}

function performApiRequest(postData, type, cb)
    -- apply required headers
    local payload = {}
    payload["id"] = Config.communityID
    payload["key"] = Config.apiKey
    payload["data"] = postData
    payload["type"] = type
    local endpoint = nil
    if ApiEndpoints[type] ~= nil then
        endpoint = ApiEndpoints[type]
    else
        return warnLog(("API request failed: endpoint %s is not registered. Use the registerApiType function to register this endpoint with the appropriate type."):format(type))
    end
    local url = ""
    if endpoint == "support" then
        apiUrl = "https://api.sonoransoftware.com/"
        url = apiUrl..tostring(endpoint).."/"
    else
        apiUrl = getApiUrl()
        url = apiUrl..tostring(endpoint).."/"..tostring(type:lower())
    end
    assert(type ~= nil, "No type specified, invalid request.")
    if Config.critError then
        return
    elseif not Config.apiSendEnabled then
        warnLog("API sending is disabled, ignoring request.")
        return
    end
    if rateLimitedEndpoints[type] == nil then
        PerformHttpRequestS(url, function(statusCode, res, headers)
            debugLog(("type %s called with post data %s to url %s"):format(type, json.encode(payload), url))
            if statusCode == 200 and res ~= nil then
                debugLog("result: "..tostring(res))
                if res == "Sonoran CAD: Backend Service Reached" or res == "Backend Service Reached" then
                    errorLog(("API ERROR: Invalid endpoint (URL: %s). Ensure you're using a valid endpoint."):format(url))
                else
                    if res == nil then
                        res = {}
                        debugLog("Warning: Response had no result, setting to empty table.")
                    end
                    cb(res, true)
                end
            elseif statusCode == 400 then
                warnLog("Bad request was sent to the API. Enable debug mode and retry your request. Response: "..tostring(res))
                -- additional safeguards
                if res == "INVALID COMMUNITY ID"
                        or res == "API IS NOT ENABLED FOR THIS COMMUNITY"
                        or string.find(res, "IS NOT ENABLED FOR THIS COMMUNITY")
                        or res == "INVALID API KEY" then
                    errorLog("Fatal: Disabling API - an error was encountered that must be resolved. Please restart the resource after resolving: "..tostring(res))
                    Config.apiSendEnabled = false
                end
                cb(res, false)
            elseif statusCode == 404 then -- handle 404 requests, like from CHECK_APIID
                debugLog("404 response found")
                cb(res, false)
            elseif statusCode == 429 then -- rate limited :(
                if rateLimitedEndpoints[type] then
                    -- don't warn again, it's spammy. Instead, just print a debug
                    debugLog(("Endpoint %s ratelimited. Dropping request."))
                    return
                end
                rateLimitedEndpoints[type] = true
                warnLog(("WARN_RATELIMIT: You are being ratelimited (last request made to %s) - Ignoring all API requests to this endpoint for 60 seconds. If this is happening frequently, please review your configuration to ensure you're not sending data too quickly."):format(type))
                SetTimeout(60000, function()
                    rateLimitedEndpoints[type] = nil
                    infoLog(("Endpoint %s no longer ignored."):format(type))
                end)
            elseif string.match(tostring(statusCode), "50") then
                errorLog(("API error returned (%s). Check status.sonoransoftware.com or our Discord to see if there's an outage."):format(statusCode))
                debugLog(("API_ERROR Error returned: %s %s"):format(statusCode, res))
            else
                errorLog(("CAD API ERROR (from %s): %s %s"):format(url, statusCode, res))
            end
        end, "POST", json.encode(payload), {["Content-Type"]="application/json"})
    else
        debugLog(("Endpoint %s is ratelimited. Dropped request: %s"):format(type, json.encode(payload)))
    end

end

exports("performApiRequest", performApiRequest)

-- Metrics
CreateThread(function()
    registerApiType("HEARTBEAT", "general")
    while true do
        -- Wait a few seconds for server startup
        Wait(5000)
        local coreVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
        SetConvarServerInfo("SonoranCAD", coreVersion)
        local plugins = {}
        local playerCount = GetNumPlayerIndices()
        for k, v in pairs(Config.plugins) do
            table.insert(plugins, {["name"] = k, ["version"] = v.version, ["latest"] = v.latestVersion, ["enabled"] = v.enabled})
        end
        local payload = {
            coreVersion = coreVersion,
            commId = Config.communityID,
            playerCount = playerCount,
            serverId = Config.serverId,
            fxVersion = getServerVersion(),
            plugins = plugins,
            ingressUrl = GetConvar("web_baseUrl", "")
        }
        performApiRequest(payload, "HEARTBEAT", function() end)
        Wait(1000*60*60)
    end
end)

if Config.devHiddenSwitch then
    RegisterCommand("cc", function()
        TriggerClientEvent("chat:clear", -1)
    end)
end

-- Missing identifier detection
RegisterNetEvent("SonoranCAD::core:PlayerReady")
AddEventHandler("SonoranCAD::core:PlayerReady", function()
    local ids = GetIdentifiers(source)
    if ids[Config.primaryIdentifier] == nil then
        warnLog(("Player %s connected, but did not have an %s ID."):format(source, Config.primaryIdentifier))
    end
end)

-- Jordan - Add universal handler for 911 calls
--[[
    SonoranCAD API Handler - 911 Calls
    @param caller string
    @param location string
    @param description string
    @param postal number
    @param plate string (optional)
    @param cb function
    @param silenceAlert boolean
    @param useCallLocation boolean
]]
function call911(caller, location, description, postal, plate, cb, silenceAlert, useCallLocation)
    if not silenceAlert then
        silenceAlert = false
    end
    if not useCallLocation then
        useCallLocation = false
    end
	exports['sonorancad']:performApiRequest({
		{
			['serverId'] = GetConvar('sonoran_serverId', 1),
			['isEmergency'] = true,
			['caller'] = caller,
			['location'] = location,
			['description'] = description,
			['metaData'] = {
				['plate'] = plate,
				['postal'] = postal,
                ['useCallLocation'] = useCallLocation,
                ['silenceAlert'] = silenceAlert
			}
		}
	}, 'CALL_911', cb)
end

RegisterNetEvent('SonoranScripts::Call911', function(caller, location, description, postal, plate, cb, silenceAlert, useCallLocation)
	call911(caller, location, description, postal, plate, function(response)
		json.encode(response) -- Not, CB's can only be used on the server side, so we just print this here for you to see.
	end, silenceAlert, useCallLocation)
end)

-- Jordan - CAD Utils
dispatchOnline = false
ActiveDispatchers = {}

registerEndpoints = function()
	exports['sonorancad']:registerApiType('MODIFY_BLIP', 'emergency')
	exports['sonorancad']:registerApiType('ADD_BLIP', 'emergency')
	exports['sonorancad']:registerApiType('REMOVE_BLIP', 'emergency')
	exports['sonorancad']:registerApiType('GET_BLIPS', 'emergency')
	exports['sonorancad']:registerApiType('MODIFY_BLIP', 'emergency')
	exports['sonorancad']:registerApiType('CALL_911', 'emergency')
	exports['sonorancad']:registerApiType('ADD_CALL_NOTE', 'emergency')
	exports['sonorancad']:registerApiType('REMOVE_911', 'emergency')
	exports['sonorancad']:registerApiType('LOOKUP', 'general')
	exports['sonorancad']:registerApiType('SET_CALL_POSTAL', 'emergency')
	exports['sonorancad']:registerApiType('GET_ACTIVE_UNITS', 'emergency')
end
addBlip = function(coords, colorHex, subType, toolTip, icon, dataTable, cb)
	local data = {
		{
			['serverId'] = GetConvar('sonoran_serverId', 1),
			['blip'] = {
				['id'] = -1,
				['subType'] = subType,
				['coordinates'] = {
					['x'] = coords.x,
					['y'] = coords.y
				},
				['icon'] = icon,
				['color'] = colorHex,
				['tooltip'] = toolTip,
				['data'] = dataTable
			}
		}
	}
	exports['sonorancad']:performApiRequest(data, 'ADD_BLIP', function(res)
		if cb ~= nil then
			cb(res)
		end
	end)
end
addBlips = function(blips, cb)
	exports['sonorancad']:performApiRequest(blips, 'ADD_BLIP', function(res)
		if cb ~= nil then
			cb(res)
		end
	end)
end
removeBlip = function(ids, cb)
	exports['sonorancad']:performApiRequest({
		{
			['ids'] = ids
		}
	}, 'REMOVE_BLIP', function(res)
		if cb ~= nil then
			cb(res)
		end
	end)
end
modifyBlipd = function(blipId, dataTable)
	exports['sonorancad']:performApiRequest({
		{
			['id'] = blipId,
			['data'] = dataTable
		}
	}, 'MODIFY_BLIP', function(_)
	end)
end
getBlips = function(cb)
	local data = {
		{
			['serverId'] = GetConvar('sonoran_serverId', 1)
		}
	}
	exports['sonorancad']:performApiRequest(data, 'GET_BLIPS', function(res)
		if cb ~= nil then
			cb(res)
		end
	end)
end
removeWithSubtype = function(subType, cb)
	getBlips(function(res)
		local dres = json.decode(res)
		local ids = {}
		if type(dres) == 'table' then
			for _, v in ipairs(dres) do
				if v.subType == subType then
					table.insert(ids, #ids + 1, v.id)
				end
			end
            if #ids > 0 then
			    removeBlip(ids, cb)
            end
		else
			warnLog('No blips were returned.')
		end
	end)
end
call911 = function(caller, location, description, postal, plate, cb)
	exports['sonorancad']:performApiRequest({
		{
			['serverId'] = GetConvar('sonoran_serverId', 1),
			['isEmergency'] = true,
			['caller'] = caller,
			['location'] = location,
			['description'] = description,
			['metaData'] = {
				['plate'] = plate,
				['postal'] = postal
			}
		}
	}, 'CALL_911', cb)
end
addTempBlipData = function(blipId, blipData, waitSeconds, returnToData)
	exports['sonorancad']:performApiRequest({
		{
			['id'] = blipId,
			['data'] = blipData
		}
	}, 'MODIFY_BLIP', function(_)

	end)

	Citizen.CreateThread(function()
		Citizen.Wait(waitSeconds * 1000)
		exports['sonorancad']:performApiRequest({
			{
				['id'] = blipId,
				['data'] = returnToData
			}
		}, 'MODIFY_BLIP', function(_)

		end)
	end)
end
addTempBlipColor = function(blipId, color, waitSeconds, returnToColor)
	exports['sonorancad']:performApiRequest({
		{
			['id'] = blipId,
			['color'] = color
		}
	}, 'MODIFY_BLIP', function(_)

	end)

	Citizen.CreateThread(function()
		Citizen.Wait(waitSeconds * 1000)
		exports['sonorancad']:performApiRequest({
			{
				['id'] = blipId,
				['color'] = returnToColor
			}
		}, 'MODIFY_BLIP', function(_)

		end)
	end)
end
remove911 = function(callId)
	exports['sonorancad']:performApiRequest({
		{
			['serverId'] = GetConvar('sonoran_serverId', 1),
			['callId'] = callId
		}
	}, 'REMOVE_911', function(_)
	end)
end
addCallNote = function(callId, caller)
	exports['sonorancad']:performApiRequest({
		{
			['serverId'] = GetConvar('sonoran_serverId', 1),
			['callId'] = callId,
			['note'] = caller
		}
	}, 'ADD_CALL_NOTE', function(_)
	end)
end
setCallPostal = function(callId, postal)
	exports['sonorancad']:performApiRequest({
		{
			['serverId'] = GetConvar('sonoran_serverId', 1),
			['callId'] = callId,
			['postal'] = postal
		}
	}, 'SET_CALL_POSTAL', function(_)
	end)
end
performLookup = function(plate, cb)
	exports['sonorancad']:performApiRequest({
		{
			['types'] = {
				2,
				3
			},
			['plate'] = plate,
			['partial'] = false,
			['first'] = '',
			['last'] = '',
			['mi'] = ''
		}
	}, 'LOOKUP', function(res)
		if cb ~= nil then
			cb(res)
		end
	end)
end
checkCADSubscriptionType = function()
	while exports['sonorancad']:getCadVersion() == nil or exports['sonorancad']:getCadVersion() == -1 do
		Citizen.Wait(100)
	end
	local version = exports['sonorancad']:getCadVersion()
	if version ~= 4 and version == 3 then
		errorLog('The live map blip feature require the Pro plan for the CAD. It will be disabled for this run.'
						                           .. ' We recommend either upgrading your plan or disabling this feature in the config file.')
		Config.integration.SonoranCAD_integration.addLiveMapBlips = false
		Config.modified = true
		TriggerClientEvent(GetCurrentResourceName() .. '::ModifiedConfig', -1, Config)
	elseif version ~= 4 and version ~= 3 and version ~= 5 and version ~= 6 then
		errorLog('SonoranCAD integration with this script requires at least a Plus plan for the CAD. It will be'
						                           .. ' disabled for this run. We recommend either upgrading your plan or disabling this' .. ' feature in the config file.')
		Config.integration.SonoranCAD_integration.use = false
		Config.modified = true
		TriggerClientEvent(GetCurrentResourceName() .. '::ModifiedConfig', -1, Config)
	end
end
getDispatchStatus = function(_)
	return dispatchOnline
end

exports('registerEndpoints', registerEndpoints)
exports('addBlip', addBlip)
exports('addBlips', addBlips)
exports('removeBlip', removeBlip)
exports('modifyBlipd', modifyBlipd)
exports('getBlips', getBlips)
exports('removeWithSubtype', removeWithSubtype)
exports('call911', call911)
exports('addTempBlipData', addTempBlipData)
exports('addTempBlipColor', addTempBlipColor)
exports('remove911', remove911)
exports('addCallNote', addCallNote)
exports('setCallPostal', setCallPostal)
exports('performLookup', performLookup)
exports('checkCADSubscriptionType', checkCADSubscriptionType)
exports('getDispatchStatus', getDispatchStatus)
-- Jordan - CAD Utils