ManagedResources = { "wk_wars2x", "tablet", "sonoran_livemap", "sonorancad"}

CreateThread(function()
    file = io.open(GetResourcePath(GetCurrentResourceName()).."/run.lock", "a+")
    io.input(file)
    line = io.read()
    if line ~= "1" then
        file:close()
        os.remove(GetResourcePath(GetCurrentResourceName()).."/run.lock")
        print("sonoran_updatehelper is for internal use and should not be started as a resource.")
        return
    end
    file:close()
    ExecuteCommand("refresh")
    Wait(1000)
    for k, v in pairs(ManagedResources) do
        ExecuteCommand("restart "..v)
        Wait(1000)
    end
end)