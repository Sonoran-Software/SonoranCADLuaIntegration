resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

dependency "yarn"
dependency "webpack"
webpack_config "webpack.config.js"

client_scripts{
    -- Live_Map
    "live_map/client/client.lua",
    "live_map/client/reverse_weapon_hashes.lua",
    "live_map/client/reverse_car_hashes.lua",
    "live_map/client/reverse_location_hashes.lua",
    "live_map/client/blips_client.lua",

    -- CAD Integration
    "cl_cad.lua"
}

exports {
    "reverseWeaponHash",
    "reverseVehicleHash",
    "reverseStreetHash",
    "reverseZoneHash",
    "reverseAreaHash"
}

server_scripts {
    -- Live_Map
    "live_map/dist/livemap.js",

    -- CAD Integration
    "sv_update_check.lua",
    "sv_cad.lua",
    "sv_listener.js"
}