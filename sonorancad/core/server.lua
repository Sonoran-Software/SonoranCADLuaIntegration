Plugins = {}

CreateThread(function()
    Wait(1)
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

function registerApiType(type, endpoint)
    ApiEndpoints[type] = endpoint
end

function performApiRequest(postData, type, cb)
    -- apply required headers 
    local payload = {}
    payload["id"] = Config.communityID
    payload["key"] = Config.apiKey
    payload["type"] = type
    payload["data"] = postData
    local endpoint = nil
    local apiUrl = Config.apiUrl
    if ApiEndpoints[type] ~= nil then
        endpoint = ApiEndpoints[type]
    end
    if endpoint == "support" then
        apiUrl = "https://api.sonoransoftware.com/"
    end
    PerformHttpRequest(apiUrl..tostring(endpoint), function(statusCode, res, headers)
        debugPrint(("type %s called with post data %s to url %s"):format(type, json.encode(payload), Config.apiUrl..tostring(endpoint)))
        if statusCode == 200 and res ~= nil then
            debugPrint("result: "..tostring(res))
            for k, v in pairs(headers) do
                debugPrint(("%s: %s"):format(k, v))
            end
            cb(res, true)
        elseif statusCode == 404 then -- handle 404 requests, like from CHECK_APIID
            cb(res, false)
        else
            errorLog(("CAD API ERROR: %s %s"):format(statusCode, res))
        end
    end, "POST", json.encode(payload), {["Content-Type"]="application/json"})
    
end