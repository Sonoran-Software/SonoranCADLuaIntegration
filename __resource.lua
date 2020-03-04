--[[
        SonoranCAD FiveM - A SonoranCAD integration for FiveM servers
              Copyright (C) 2020  Sonoran Software Systems LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program in the file "LICENSE".  If not, see <http://www.gnu.org/licenses/>.
]]

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

--[[ NOTE: You might need to comment out the following two dependencies once the server is fully started up once. 
    In testing clients could not connect if they were uncommented. Make sure you allow the resource to build the code first!]]
dependency "yarn"
dependency "webpack"
webpack_config "webpack.config.js"

server_scripts {
    -- CAD Integration
    '@mysql-async/lib/MySQL.lua',
    "server/sv_update_check.lua",
    "server/sv_cad.lua",
    "server/sv_esx.lua",
    "server/sv_listener.js",
    
    -- Live_Map
    "dist/livemap.js"
}

client_scripts{
    -- CAD Integration
    "client/cl_cad.lua",
    "client/cl_esx.lua",

    -- Live_Map
    "client/cl_livemap.lua",
    "client/reverse_weapon_hashes.lua",
    "client/reverse_car_hashes.lua",
    "client/reverse_location_hashes.lua",
    "client/blips_client.lua"
}

exports {
    "reverseWeaponHash",
    "reverseVehicleHash",
    "reverseStreetHash",
    "reverseZoneHash",
    "reverseAreaHash"
}