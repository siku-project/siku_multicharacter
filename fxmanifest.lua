fx_version 'cerulean'
game 'gta5'

author 'Siku Studio'
description 'The official multicharacter system of the SIKU ecosystem — a modern, modular and immersive resource for creating, managing, and selecting player characters with seamless integration and a polished user experience.'
version '0.1.0'

name 'siku_multicharacter'

lua54 'yes'

shared_scripts {
  '@siku_core/init.lua',
  'config/*.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/init.lua',
  'server/modules/**/*.lua',
}

client_scripts {
  'client/modules/**/*.lua',
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
