ManagedResources = { "wk_wars2x", "tablet", "sonoran_livemap", "sonorancad"}

CreateThread(function()
    file = io.open(GetResourcePath(GetCurrentResourceName()).."/run.lock", "a+")
    io.input(file)
    line = io.read()
    file:close()
    if line == "core" or line == "plugin" then
        ExecuteCommand("refresh")
        Wait(1000)
        if line == "core" then
            for k, v in pairs(ManagedResources) do
                ExecuteCommand("restart "..v)
                Wait(1000)
            end
        elseif line == "plugin" then
            print("Restarting sonorancad resource for plugin updates...")
            ExecuteCommand("restart sonorancad")
        end
    else
        os.remove(GetResourcePath(GetCurrentResourceName()).."/run.lock")
        print("sonoran_updatehelper is for internal use and should not be started as a resource.")
    end
end)