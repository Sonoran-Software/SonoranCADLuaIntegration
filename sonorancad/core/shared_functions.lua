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

--[[
    Checks if either ID causes callback to return a positive (non-falsey) value
]]
function CheckIdentifiers(id1, id2, callback, stripPrefix)
    if stripPrefix then
        prefix1, id1 = id1:match("^(.+):(.+)$")
        prefix2, id2 = id2:match("^(.+):(.+)$")
    end
    local r1 = callback(id1)
    if r1 ~= nil and r1 ~= false then
        return r1
    else
        if id2 ~= nil and id2 ~= "" then
            local r2 = callback(id2)
            if r2 ~= nil and r1 ~= false then
                return r2
            else
                return r1
            end
        else
            return r1
        end
    end
end