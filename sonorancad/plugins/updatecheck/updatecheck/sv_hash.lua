function CheckHashes(pluginName, callback)
    local ok = true
    CreateThread(function()
        local f = nil
        if pluginName == "core" then
            f = LoadResourceFile(GetCurrentResourceName(), "manifest.json")
        else
            f = LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/manifest.json"):format(pluginName, pluginName))
            if f == nil then
                f = LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/manifest.json"):format(pluginName))
            end
        end
        if f then
            local files = json.decode(f)
            if not files then
                warnLog(("Failed to read manifest for plugin %s. Is it valid? Actual file: %s"):format(pluginName, f))
                return
            end
            for name, hash in pairs(files) do
                local currentFile = LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s"):format(pluginName, name))
                if currentFile == nil then
                    currentFile = LoadResourceFile(GetCurrentResourceName(), ("plugins/%s/%s/%s"):format(pluginName, pluginName, name))
                end
                if currentFile == nil then
                    currentFile = LoadResourceFile(GetCurrentResourceName(), ("core/%s"):format(name))
                end
                if currentFile ~= nil then
                    local currentHash = HashString(currentFile)
                    if currentHash ~= string.lower(hash) then
                        warnLog(("Hash mismatch - Plugin: %s - File: %s - Hashes: %s ~= %s"):format(pluginName, name, currentHash, hash))
                        ok = false
                    else
                        debugLog(("Hash OK - Plugin: %s - File: %s - Hash: %s"):format(pluginName, name, currentHash))
                    end
                else
                    warnLog("File missing! "..name)
                    ok = false
                end
            end
        else
            warnLog("Missing manifest file.")
            ok = false
        end
        callback(ok)
    end)
end

function HashString(str)
    local m = md5.new()
    m:update(str)
    return md5.tohex(m:finish())
end