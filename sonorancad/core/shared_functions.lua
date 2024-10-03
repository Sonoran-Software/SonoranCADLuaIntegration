function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

-- Helper function to determine index of given identifier
function findIndex(identifier)
    for i,loc in ipairs(LocationCache) do
        if loc.apiId == identifier then
            return i
        end
    end
end


function GetIdentifiers(player)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(player)) do
        local split = stringsplit(id, ":")
        ids[split[1]] = split[2]
    end
    --debugLog("Returning "..json.encode(ids))
    return ids
end

function isPluginLoaded(pluginName)
    for k, v in pairs(Plugins) do
        if v == pluginName then
            return true
        end
    end
    return false
end

exports('isPluginLoaded', isPluginLoaded)

function PerformHttpRequestS(url, cb, method, data, headers)
    if not data then
        data = ""
    end
    if not headers then
        headers = {["X-User-Agent"] = "SonoranCAD"}
    end
    exports["sonorancad"]:HandleHttpRequest(url, cb, method, data, headers)
end

function has_value(tab, val)
    if tab == nil then
        debugLog("nil passed to has_value, ignore")
        return false
    end
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function getServerVersion()
    local s = GetConvar("version", "")
    local v = s:find("v1.0.0.")
    local e = string.gsub(s:sub(v),"v1.0.0.","")
    local i = e:sub(1, string.len(e) - e:find(" "))
    return i
end

function compareVersions(version1, version2)
    _, _, v1, v2, v3 = string.find( version1, "(%d+)%.(%d+)%.(%d+)" )
    _, _, r1, r2, r3 = string.find( version2, "(%d+)%.(%d+)%.(%d+)" )
    if r3 == nil then r3 = 0 end
    if v3 == nil then v3 = 0 end
    if r2 == nil then r2 = 0 end
    if v2 == nil then v2 = 0 end
    if v1 == nil then v1 = 1 end
    if r1 == nil then r1 = 1 end
    local parsedVersion2 = r3+(r2*100)+(r1*1000)
    local parsedVersion1 = v3+(v2*100)+(v1*1000)
    local tbl = { result = (parsedVersion2 < parsedVersion1), parsedVersion1 = parsedVersion1, parsedVersion2 = parsedVersion2, version1 = version1, version2 = version2 }
    debugLog(json.encode(tbl))
    return tbl
end