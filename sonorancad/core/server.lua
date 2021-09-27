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
    Config.apiUrl = getApiUrl()
    performApiRequest({}, "GET_VERSION", function(result, ok)
        if not ok then
            errorLog("Failed to get version information. Is the API down? Please restart sonorancad.")
            Config.critError = true
            return
        end
        Config.apiVersion = tonumber(string.sub(result, 1, 1))
        if Config.apiVersion < 2 then
            errorLog("ERROR: Your community cannot use any plugins requiring the API. Please purchase a subscription of Standard or higher.")
            Config.critError = true
        end
        debugLog(("Set version %s from response %s"):format(Config.apiVersion, result))
        infoLog(("Loaded community ID %s with API URL: %s"):format(Config.communityID, Config.apiUrl))
    end)
    if Config.primaryIdentifier == "steam" and GetConvar("steam_webapiKey", "none") == "none" then
        errorLog("You have set SonoranCAD to Steam mode, but have not configured a Steam Web API key. Please see FXServer documentation. SonoranCAD will not function in Steam mode without this set.")
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
    ["ADD_CALL_NOTE"] = "emergency"
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
                    cb(res, true)
                end
            elseif statusCode == 400 then
                warnLog("Bad request was sent to the API. Enable debug mode and retry your request. Response: "..tostring(res))
                -- additional safeguards
                if res == "INVALID COMMUNITY ID"
                        or res == "API IS NOT ENABLED FOR THIS COMMUNITY"
                        or res == "INVALID API KEY" then
                    errorLog("Fatal: Disabling API - an error was encountered that must be resolved. Please restart the resource after resolving.")
                    Config.apiSendEnabled = false
                end
                assert(res ~= "INVALID COMMUNITY ID", "Your community ID is invalid!")
                assert(res ~= "API IS NOT ENABLED FOR THIS COMMUNITY", "You do not have access to the API.")
                assert(res ~= "INVALID API KEY", "Your API Key is invalid. Please verify the configuration.")
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
                warnLog(("You are being ratelimited (last request made to %s) - Ignoring all API requests to this endpoint for 60 seconds. If this is happening frequently, please review your configuration to ensure you're not sending data too quickly."):format(type))
                SetTimeout(60000, function()
                    rateLimitedEndpoints[type] = nil
                    infoLog(("Endpoint %s no longer ignored."):format(type))
                end)
            elseif string.match(tostring(statusCode), "50") then
                errorLog(("API error returned (%s). Check status.sonoransoftware.com or our Discord to see if there's an outage."):format(statusCode))
                debugLog(("Error returned: %s %s"):format(statusCode, res))
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
            plugins = plugins
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