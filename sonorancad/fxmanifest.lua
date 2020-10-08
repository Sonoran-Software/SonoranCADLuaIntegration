fx_version 'bodacious'
games {'gta5'}

author 'Sonoran CAD'
description 'Sonoran CAD FiveM Integration'
version '2.2.0'

lua54 'lua54'

server_scripts {
    'core/http.js'
    ,'core/unzipper/unzip.js'
    ,'core/shared_functions.lua'
    ,'core/configuration.lua'
    ,'config.lua'
    ,'core/logging.lua'
    ,'core/server.lua'
    ,'core/commands.lua'
    ,'core/httpd.lua'
    ,'core/updater.lua'
    ,'plugins/**/config_*.lua'
    ,'plugins/**/sv_*.lua'
    ,'plugins/**/sv_*.js'
    ,'core/plugin_loader.lua'
    ,'@mysql-async/lib/MySQL.lua' -- if not using ESX, you can remove this line
               }
client_scripts {
    'core/shared_functions.lua'
    ,'core/logging.lua'
    ,'core/client.lua'
    ,'plugins/**/config_*.lua'
    ,'plugins/**/cl_*.lua'
    ,'plugins/**/cl_*.js'
} 