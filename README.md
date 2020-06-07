# SonoranCADLuaIntegration
Sonoran CAD's Lua integration scripts allow you to update unit locations in real time, access /911, /311, /panic, and view unit identifier information on a live map.

## Installing

1) Create a folder called `[sonorancad]` in your resources folder. The brackets are important.
1) Checkout the contents of this repository into your new folder, or grab the latest release from Releases.
2) Open `config.CHANGEME.lua`, change the config values, then rename it to `config.lua`
3) If **not** using ESX, open `fxmanifest.lua` and comment the MySQL lua file and the dependency.
4) Start.

## Advanced Configuration: Postal Integration

The integration includes the `postals` plugin which allows you to send postal codes to the CAD. See `sonorancad/plugins/postals` for details of how to configure.

## Advanced Configuration: API Integration

SonoranCAD offers read access to your CAD data, making it very useful to use for integration with various scripts. Detailed information can be found [here](https://info.sonorancad.com/sonoran-cad/api-integration/api-endpoints/).

The plugin `lookups` contains name and plate lookup functionality. See `sonorancad/plugins/lookups` for detailed information.

### Bonus Integration: wk_wars2k Plate Scan Search

SonoranCAD comes bundled with a [popular radar resource](https://forum.cfx.re/t/release-wraith-ars-2x-police-radar-and-plate-reader-v1-2-4/1058277) which allows you to automatically search plates in the CAD. See `sonorancad/plugins/radar_wraithv2` for detailed information.

### Bonus Integration: Tablet

This integration script includes a very basic "tablet" so you can use the CAD in-game via the `tablet` resource. Check out `tablet\html\index.html` to edit the link with your custom page.