# SonoranCAD FiveM Integration
**NOW INCLUDES HOSTED LIVE MAP INTEGRATION!**

This Integration functions to send player data from FiveM to the SonoranCAD API. Recent updates have added example commands, the ability to recieve data from SonoranCAD, live map integration, and ESX framework integration.

## How to install

1. Download the [ZIP file](https://github.com/SonoranBrian/SonoranCADLuaIntegration/archive/master.zip). And extract the contents into `resources/sonorancad/`.

2. Add the following to your **server.cfg** file.

```
set SonoranListenPort 3232
set socket_port 30121
set livemap_debug "warn" # "[all]" 'trace', 'debug', 'info', 'warn', 'error', 'fatal', 'off'
set blip_file "server/blips.json"
set livemap_access_control "*"

start sonorancad
```

3. Configure the config.json file for your SonoranCAD Community. A table on the "REQUIRED" changes can be found below...

NOTE: To get the in-game blips to show on the live map interface, you will need to generate a "blips" file.
This can be easily done with the in-game command `blips generate` (must be ran as admin).

## Configuration

### Config.json
The following options in the config.json file are available for you to change

| Name                    | Type           | Default Value       | Description |
| ----------------------- | -------------  | ------------------: | ----------- |
| communitiyId            | string         | ""                  | REQUIRED TO CHANGE: Set this to your Community ID found on SonoranCAD's Community Admin Panel (pictured below) |
| apiKey                  | string         | ""                  | REQUIRED TO CHANGE: Set this to your API Key found on SonoranCAD's Community Admin Panel (pictured below)  |
| apiUrl                  | string         | "https://sonorancad.com/api/emergency" | This is already set to the default API URL for all SonoranCAD API communications |
| locationPostTime        | int            | 5000                | Lowering this value will result in rate limiting by SonoranCAD, must be higher than 5000 miliseconds |
| serverType              | string         | "esx"               | OPTIONAL: Set this to one of the following options indicating what mode you want to run in. ("**standalone**" or "**esx**") |
| jobsTracked             | array of strings| ["police","ambulance"] | OPTIONAL: Set this to the job names that you want tracked on the SonoranCAD live map. |

**NOTE: standalone mode will show all players on the SonoranCAD live map integration**

![SonoranCAD Community Admin Panel Instructions](https://sonoransoftware.com/tutorials/sonorancad/images/integration_api_keys.png "Get your Community ID and apiKey here")

### Convars
The following convars are available for you to change. We suggest you include these options in your server.cfg, but it is NOT REQUIRED. Just make sure you have opened the default ports or the ports you change the convar-based settings to.

| Name                    | Type           | Default Value       | Description |
| ----------------------- | -------------  | ------------------: | ----------- |
| SonoranListenPort       | int            | 3232                | Sets the port the SonoranCAD Listener to recieve inbound API requests on |
| socket_port             | int            | 30121               | Sets the port the socket server should listen on |
| livemap_debug           | int            | 0                   | Sets how much information gets printed to the console (0 = none, 1 = basic information, 2 = all) |
| blip_file               | string         | "server/blips.json" | Sets the file that will contain the generated blips that is exposed via HTTP |
| livemap_access_control  | string         | "*"                 | Sets the domain that is allowed to access the blips.json file (E.g. "https://example.com" will only allow the UI on http://example.com to get the blips), "*" will allow everyone |

## Built with
* [THRHavoc/live_map](https://github.com/TGRHavoc/live_map)
* [Hellslicer/WebSocketServer](https://github.com/Hellslicer/WebSocketServer/blob/master/WebSocketEventListener.cs)
* [deniszykov/WebSocketListener](https://github.com/deniszykov/WebSocketListener)
* [JamesNK/Newtonsoft.Json](https://github.com/JamesNK/Newtonsoft.Json)
