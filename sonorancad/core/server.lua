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
            assert(false, "Invalid mode. Valid values are production, development")
        end
    end
end

CreateThread(function()
    Wait(1)
    Config.apiUrl = getApiUrl()
    infoLog(("Loaded community ID %s with API URL: %s"):format(Config.communityID, Config.apiUrl))
end)

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- Helper function to get the ESX Identity object
function getIdentity(source)
    local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
    if Config.primaryIdentifier == "steam" then
        identifier = ("steam:%s"):format(identifier)
    end
    local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    if result[1] ~= nil then
        local identity = result[1]

        return {
            identifier = identity['identifier'],
            firstname = identity['firstname'],
            lastname = identity['lastname'],
            dateofbirth = identity['dateofbirth'],
            sex = identity['sex'],
            height = identity['height']
        }
    else
        return nil
    end
end

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
    ["UNIT_PANIC"] = "emergency"
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

local rateLimitedEndpoints = {}

function performApiRequest(postData, type, cb)
    -- apply required headers 
    local payload = {}
    payload["id"] = Config.communityID
    payload["key"] = Config.apiKey
    payload["data"] = postData
    payload["type"] = type
    local endpoint = nil
    local apiUrl = Config.apiUrl
    if ApiEndpoints[type] ~= nil then
        endpoint = ApiEndpoints[type]
    end
    if endpoint == "support" then
        apiUrl = "https://api.sonoransoftware.com/"
    else
        apiUrl = getApiUrl()
    end
    assert(type ~= nil, "No type specified, invalid request.")
    local url = Config.apiUrl..tostring(endpoint).."/"..tostring(type:lower())
    if rateLimitedEndpoints[type] == nil then
        PerformHttpRequest(url, function(statusCode, res, headers)
            debugLog(("type %s called with post data %s to url %s"):format(type, json.encode(payload), url))
            if statusCode == 200 and res ~= nil then
                debugLog("result: "..tostring(res))
                if res == "Sonoran CAD: Backend Service Reached" then
                    errorLog(("API ERROR: Invalid endpoint (URL: %s). Ensure you're using a valid endpoint."):format(url))
                else
                    cb(res, true)
                end
            elseif statusCode == 404 then -- handle 404 requests, like from CHECK_APIID
                cb(res, false)
            elseif statusCode == 429 then -- rate limited :(
                rateLimitedEndpoints[type] = true
                warnLog(("You are being ratelimited (last request made to %s) - Ignoring all API requests to this endpoint for 30 seconds."):format(type))
                SetTimeout(30000, function()
                    rateLimitedEndpoints[type] = nil
                    infoLog(("Endpoint %s no longer ignored."):format(type))
                end)
            else
                errorLog(("CAD API ERROR: %s %s"):format(statusCode, res))
            end
        end, "POST", json.encode(payload), {["Content-Type"]="application/json"})
    else
        debugLog(("Endpoint %s is ratelimited. Dropped request: %s"):format(type, json.encode(payload)))
    end
    
end

-- Metrics
CreateThread(function()
    registerApiType("HEARTBEAT", "general")
    while true do
        -- Wait a few seconds for server startup
        Wait(5000)
        local coreVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
        local plugins = {}
        local playerCount = GetNumPlayerIndices()
        for k, v in pairs(Config.plugins) do
            table.insert(plugins, {["name"] = k, ["version"] = v.version, ["latest"] = v.latestVersion, ["enabled"] = v.enabled})
        end
        local payload = {
            coreVersion = coreVersion,
            commId = Config.communityID,
            playerCount = playerCount,
            plugins = plugins
        }
        debugLog(("Heartbeat: %s"):format(json.encode(payload)))
        --performApiRequest(payload, "HEARTBEAT", function() end) (purposely commented until endpoint is available)
        Wait(1000*60*60)
    end
end)