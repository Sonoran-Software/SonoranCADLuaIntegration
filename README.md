# SonoranCADLuaIntegration
Sonoran CAD's Lua integration scripts allow you to update unit locations in real time, access /911, /311, /panic, and view unit identifier information on a live map.

## Installing

1) Checkout the contents into your resources folder.
2) Open `config.CHANGEME.lua`, change the config values, then rename it to `config.lua`
3) If **not** using ESX, open `fxmanifest.lua` and comment the MySQL lua file and the dependency.
4) Start.

## Advanced Configuration: Postal Integration

If your server has a script to get the nearest postal code, you can modify `postal_client.lua` so this information is used with this resource. See `config.lua` for details.