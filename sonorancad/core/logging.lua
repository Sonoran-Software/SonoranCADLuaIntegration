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