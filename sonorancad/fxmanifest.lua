fx_version 'bodacious'
games {'gta5'}

author 'Sonoran CAD'
description 'Sonoran CAD FiveM Integration'
version '2.0.0-alpha5'

server_scripts {
    'core/shared_functions.lua'
    ,'core/configuration.lua'
    ,'config.lua'
    ,'core/logging.lua'
    ,'core/server.lua'
    ,'plugins/**/config_*.lua'
    ,'plugins/**/sv_*.lua'
    ,'core/plugin_loader.lua'
    ,'@mysql-async/lib/MySQL.lua' -- if not using ESX, you can remove this line
               }
client_scripts {
    'core/shared_functions.lua'
    ,'core/client.lua'
    ,'plugins/**/config_*.lua'
    ,'plugins/**/cl_*.lua'
} 

dependency 'mysql-async' -- remove if not using ESX