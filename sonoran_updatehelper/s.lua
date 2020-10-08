ManagedResources = { "wk_wars2x", "tablet", "pNotify", "sonoran_livemap", "sonorancad"}

CreateThread(function()
    ExecuteCommand("refresh")
    Wait(1000)
    for k, v in pairs(ManagedResources) do
        ExecuteCommand("restart "..v)
        Wait(1000)
    end
end)