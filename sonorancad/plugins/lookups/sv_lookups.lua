--[[
    Sonaran CAD Plugins

    Plugin Name: lookups
    Creator: SonoranCAD
    Description: Implements the name/plate lookup API
]]

local pluginConfig = Config.plugins["lookups"]

registerApiType("LOOKUP_PLATE", "emergency")
registerApiType("LOOKUP_NAME", "emergency")

local PlateCache = {}

local Plate = {
    plateNumber = nil,
    lastFetched = nil,
    regInfo = nil
}
function Plate.Create(plateNumber, regInfo)
    local self = shallowcopy(Plate)
    self.plateNumber = plateNumber
    self.regInfo = {["vehicleRegistrations"] = regInfo}
    self.lastFetched = GetGameTimer()
    return self
end

function Plate:UpdateCache(regInfo)
    self.regInfo = regInfo
    self.lastFetched = GetGameTimer()
end

--[[
    cadNameLookup
        first: First Name
        last: Last Name
        mi: Middle Initial
        callback: function called with return data
]]
function cadNameLookup(first, last, mi, callback)
    local data = {}
    data["first"] = first ~= nil and first or ""
    data["last"] = last ~= nil and last or ""
    data["mi"] = mi ~= nil and mi or ""
    
    performApiRequest({data}, "LOOKUP_NAME", function(result)
        debugPrint("name lookup: "..tostring(result))
        local lookup = json.decode(result)
        callback(lookup)
    end)
end

--[[
    cadPlateLookup
        plate: plate number
        basicFlag: true returns cached record if possible which only contains vehicleRegistrations object, false calls the API
        callback: the function called with the return data
]]
function cadPlateLookup(plate, basicFlag, callback)
    local data = {}
    data["plate"] = plate:gsub("%s+","")
    if PlateCache[data["plate"]] ~= nil and basicFlag then
        local currentTime = GetGameTimer()
        local expireTime = PlateCache[data["plate"]].lastFetched + (pluginConfig.maxCacheTime * 1000)
        if currentTime <= expireTime then
            -- cache hit
            callback(PlateCache[data["plate"]].regInfo) 
        else
            -- cache miss
            debugPrint(("Plate %s out of date, fetching."):format(data["plate"]))
            performApiRequest({data}, "LOOKUP_PLATE", function(result)
                debugPrint("plate lookup: "..tostring(result))
                local lookup = json.decode(result)
                PlateCache[data["plate"]]:UpdateCache(lookup["vehicleRegistrations"])
                callback(lookup)
            end)
        end
    else
        -- not cached
        debugPrint(("Plate %s not cached or basicFlag not set, fetching."):format(data["plate"]))
        performApiRequest({data}, "LOOKUP_PLATE", function(result)
            debugPrint("plate lookup: "..tostring(result))
            local lookup = json.decode(result)
            local plate = Plate.Create(data["plate"], lookup["vehicleRegistrations"])
            PlateCache[data["plate"]] = plate
            callback(lookup)
        end)
    end
end

exports('cadNameLookup', cadNameLookup)
exports('cadPlateLookup', cadPlateLookup)

-- The follow two commands are for developer use to analyze API responses

RegisterCommand("platefind", function(source, args, rawCommand)
    if args[1] ~= nil then
        cadPlateLookup(args[1], true, function(data)
            print(("Raw data: %s"):format(json.encode(data)))
        end)
    end
end, true)

RegisterCommand("namefind", function(source, args, rawCommand)
    if args[1] ~= nil then
        local firstName = args[1]
        local lastName = args[2] ~= nil and args[2] or ""
        local mi = args[3] ~= nil and args[3] or ""
        cadNameLookup(firstName, lastName, mi, function(data)
            print(("Raw data: %s"):format(json.encode(data)))
        end)
    end
end, true)
