local function getConfig()
    local config = LoadResourceFile(GetCurrentResourceName(), "config.json")
    return config
end

SetHttpHandler(function(req, res)
    local path = req.path
    local method = req.method

    if method == 'POST' and path == '/info' then
        req.setDataHandler(function(body)
            if not body then
                res.send(json.encode({["error"] = "bad request"}))
                return
            end
            local data = json.decode(body)
            if not data then
                res.send(json.encode({["error"] = "bad request"}))
            elseif Config.critError then
                res.send(json.encode({["error"] = "critical config error"}))
            elseif string.upper(data.password) ~= string.upper(Config.apiKey) then
                res.send(json.encode({["error"] = "bad request"}))
            else
                res.send(json.encode({
                    ["status"] = "ok", 
                    ["cadInfo"] = string.gsub(dumpInfo(), "\n", "<br />"), 
                    ["config"] = string.gsub(getConfig(), "\r\n", "<br />")..string.gsub(json.encode(Config.plugins), "}", "} <br />"),
                    ["console"] = string.gsub(GetConsoleBuffer(), "\n", "<br />")
                }))
            end
        end)
    else
        if path == '/' then
            local html = LoadResourceFile(GetCurrentResourceName(), '/core/html/index.html')
            res.send(html)
        else
            res.send("hmm")
        end
    end

end)