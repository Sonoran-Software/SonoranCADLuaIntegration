# SonoranCADLuaIntegration
Sonoran CAD's Lua integration scripts allow you to update unit locations in real time, access /911, /311, /panic, and view unit identifier information on a live map.

## Installing

1) Checkout the contents into your resources folder.
2) Open `config.CHANGEME.lua`, change the config values, then rename it to `config.lua`
3) If **not** using ESX, open `fxmanifest.lua` and comment the MySQL lua file and the dependency.
4) Start.

## Advanced Configuration: Postal Integration

If your server has a script to get the nearest postal code, you can modify `postal_client.lua` so this information is used with this resource. See `config.lua` for details.

## Advanced Configuration: API Integration

SonoraCAD offers read access to your CAD data, making it very useful to use for integration with various scripts. Detailed information can be found [here](https://info.sonorancad.com/sonoran-cad/api-integration/api-endpoints/lookup-name-or-plate). The integration provides a basic wrapper to get your data, as follows:

```lua
function getNameLookup(firstName, middleInitial, lastName, callback)

function plateLookup(plate, callback)
```

`callback` is a function the lookup calls when completed, much like a database call or `PerformHttpRequest`. When called, both will return objects with the result data. See the above API documentation.

The script also provides the commands `namefind` and `platefind` to you which outputs the raw JSON response to the console, making this useful for seeing what data returns.

### Bonus Example: wk_wars2k Plate Scan Search

The following code is a implementation example using the ALPR (plate reader) function of a [popular radar resource](https://forum.cfx.re/t/release-wraith-ars-2x-police-radar-and-plate-reader-v1-2-4/1058277):

```lua

RegisterNetEvent("wk:onPlateLocked")
AddEventHandler("wk:onPlateLocked", function(cam, plate, index)
    local source = source
    exports.cad:cadPlateLookup(plate, function(data)
        local reg = data.vehicleRegistrations[1] -- scanner is always full lookup
        if reg then
            local mi = reg.person.mi ~= "" and ", "..reg.person.mi or ""
            print(("DATA: Plate [%s]: S: %s E: %s O: %s"):format(reg.vehicle.plate, reg.status, reg.expiration, reg.person.first.." "..reg.person.last..mi))
            
            TriggerClientEvent("chat:addMessage", source, {args = {"^3 ALPR ^0", ("Plate [%s]: Status: %s Expires: %s Owner: %s"):format(reg.vehicle.plate, reg.status, reg.expiration, reg.person.first.." "..reg.person.last..mi)}})
        else
            TriggerClientEvent("chat:addMessage", source, {args = {"^3 ALPR ^0", "No license records found for locked plate." }})
        end
    end)
end)
```