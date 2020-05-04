--[[
    Sonoran CAD API Handler
]]

function performApiRequest(postData, type, cb)
    -- apply required headers
    local payload = {}
    payload["id"] = communityID
    payload["key"] = apiKey
    payload["type"] = type
    payload["data"] = {postData}
    PerformHttpRequest(apiURL, function(statusCode, res, headers) 
        if statusCode == 200 and res ~= nil then
            cb(res)
        else
            print(("CAD API ERROR: %s %s"):format(statusCode, res))
        end
    end, "POST", json.encode(payload), {["Content-Type"]="application/json"})
end

function nameLookup(first, last, mi, callback)
    local data = {}
    data["first"] = first ~= nil and first or ""
    data["last"] = last ~= nil and last or ""
    data["mi"] = mi ~= nil and mi or ""
    
    performApiRequest(data, "LOOKUP_NAME", function(result)
        local lookup = json.decode(result)
        callback(lookup)
    end)
end

function plateLookup(plate, callback)
    local data = {}
    data["plate"] = plate
    performApiRequest(data, "LOOKUP_PLATE", function(result)
        local lookup = json.decode(result)
        callback(lookup)
    end)
end

exports('cadNameLookup', nameLookup)
exports('cadPlateLookup', plateLookup)

-- The follow two commands are for developer use to analyze API responses

RegisterCommand("platefind", function(source, args, rawCommand)
    if args[1] ~= nil then
        plateLookup(args[1], function(data)
            print(("Raw data: %s"):format(json.encode(data)))
        end)
    end
end, true)

RegisterCommand("namefind", function(source, args, rawCommand)
    if args[1] ~= nil then
        local firstName = args[1]
        local lastName = args[2] ~= nil and args[2] or ""
        local mi = args[3] ~= nil and args[3] or ""
        nameLookup(firstName, lastName, mi, function(data)
            print(("Raw data: %s"):format(json.encode(data)))
        end)
    end
end, true)