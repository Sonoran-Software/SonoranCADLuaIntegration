fx_version 'cerulean'
games {'gta5'}

author 'Sonoran CAD'
description 'Sonoran CAD FiveM Integration'
version '3.0.0'

server_scripts {
    'config.lua'
    ,'server/utils/*.js'
    ,'server/unzipper/unzip.js'
    ,'server/image.js'
    ,'server/logging.lua'
    ,'server/shared_functions.lua'
    ,'server/configuration.lua'
    ,'server/server.lua'
    ,'server/commands.lua'
    ,'server/httpd.lua'
    ,'server/unittracking.lua'
    ,'server/updater.lua'
    ,'server/apicheck.lua'
    ,'server/screenshot.lua'
    ,'modules/**/sv_*.lua'
    ,'modules/**/sv_*.js'
}
client_scripts {
    'server/logging.lua'
    ,'server/headshots.lua'
    ,'server/shared_functions.lua'
    ,'client/client.lua'
    ,'client/lighting.lua'
    ,'modules/**/cl_*.lua'
    ,'modules/**/cl_*.js'
}

ui_page 'client/client_nui/index.html'

files {
    'stream/**/*.ytyp',
    'client/client_nui/index.html',
    'client/client_nui/js/*.js',
    'client/client_nui/sounds/*.mp3',
    'client/client_nui/img/logo.gif'
}

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'
