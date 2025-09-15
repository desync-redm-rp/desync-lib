fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'desync-lib'
author 'Replicated from ox_lib for RedM'
version '1.0.0'
license 'LGPL-3.0-or-later'
repository 'https://github.com/your-repo/desync-lib'
description 'A library of shared functions to utilise in other RedM resources.'

dependencies {
    '/server:7290',
    '/onesync',
}

ui_page 'web/index.html'

files {
    'init.lua',
    'resource/settings.lua',
    'imports/**/client.lua',
    'imports/**/shared.lua',
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'locales/*.json',
}

shared_script 'resource/init.lua'

shared_scripts {
    'resource/**/shared.lua',
    'imports/print/shared.lua',
    'imports/waitFor/shared.lua',
    'imports/math/shared.lua',
    'imports/table/shared.lua',
    'imports/string/shared.lua',
    'imports/getClosestPed/shared.lua',
    'imports/getClosestVehicle/shared.lua',
    'imports/getNearbyPeds/shared.lua',
    'imports/getNearbyVehicles/shared.lua',
    'imports/streamingRequest/shared.lua',
    'imports/zones/shared.lua',
}

client_scripts {
    'resource/**/client.lua',
    'resource/**/client/*.lua',
    'resource/interface/client/*.lua',
    'imports/**/client.lua',
    'test-desync/client.lua'
}

server_scripts {
    'imports/callback/server.lua',
    'resource/server.lua',
    'test-desync/server.lua'
}
