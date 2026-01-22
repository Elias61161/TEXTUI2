fx_version 'cerulean'
game 'gta5'

name 'qs-textui'
description 'TextUI System - Based on lunar_bridge'
version '1.0.0'
author 'Converted from lunar_bridge'

lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/index.js',
    'html/fonts/*.ttf'
}