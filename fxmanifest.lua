fx_version 'cerulean'
game 'gta5'

author 'Siku Studio'
description 'The official multicharacter system of the SIKU ecosystem: account routing, character selection, identity and appearance creation, spawning.'
version '2.0.0'

name 'siku_multicharacter'

lua54 'yes'

shared_scripts {
  '@siku_core/init.lua',
  'config/*.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/init.lua',
  'server/modules/*.lua',
}

client_scripts {
  'client/siku_ui.lua',
  'client/nui.lua',
  'client/modules/look/*.lua',
  'client/modules/*.lua',
}

ui_page 'web/dist/index.html'

files {
  'translations/*.lua',
  'web/dist/**/*',
}

dependencies {
  'siku_core',
  'oxmysql',
}
