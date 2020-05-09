fx_version 'bodacious'
games {'gta5'}

server_scripts {
                'core/configuration.lua'
                ,'core/logging.lua'
                ,'core/server.lua'
                ,'plugins/**/config_*.lua'
                ,'plugins/**/sv_*.lua'
                ,'core/plugin_loader.lua'
                ,'@mysql-async/lib/MySQL.lua' -- if not using ESX, you can remove this line
               }
client_scripts {
    'core/client.lua'
    ,'plugins/**/cl_*.lua'
} 

dependency 'mysql-async' -- remove if not using ESX