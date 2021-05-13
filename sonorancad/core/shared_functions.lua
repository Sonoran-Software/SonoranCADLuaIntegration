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

function GetSourceByApiId(apiIds)
    for x=1, #apiIds do
        for i=0, GetNumPlayerIndices()-1 do
            local player = GetPlayerFromIndex(i)
            if player then
                local identifiers = GetIdentifiers(player)
                for type, id in pairs(identifiers) do
                    if id == apiIds[x] then
                        return player
                    end
                end
            end
        end
    end
    return nil
end

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