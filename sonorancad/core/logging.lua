local function sendConsole(level, message)
    print(("[SonoranCAD:%s] %s"):format(level, message))
end

function debugLog(message)
    if Config.debugMode then
        sendConsole("DEBUG", message)
    end
end

function debugPrint(message)
    debugLog(message)
end

function errorLog(message)
    sendConsole("ERROR", message)
end

function infoLog(message)
    sendConsole("INFO", message)
end

-- command to toggle debug mode, console only
RegisterCommand("caddebug", function()
    if source ~= nil then
        print("Console only command!")
        return
    end
    Config.debugMode = not Config.debugMode
    infoLog(("Debug mode toggled to %s"):format(Config.debugMode))
end, true)