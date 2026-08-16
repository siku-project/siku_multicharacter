fx_version 'cerulean'
game 'gta5'

author 'Siku Studio'
description 'The official multicharacter system of the SIKU ecosystem — a modern, modular and immersive resource for creating, managing, and selecting player characters with seamless integration and a polished user experience.'
version '0.1.0'

name 'siku_multicharacter'

lua54 'yes'

shared_scripts {
  '@siku_core/init.lua',
  'config/translation.lua',
  'shared/utils/locale.lua',
}

server_scripts {
  'server/init.lua',
  'server/main.lua',
}

client_scripts {
  'client/main.lua',
}

ui_page 'web/dist/index.html'

files {
  'translations/*.lua',
  'web/dist/**/*',
}

dependencies {
  'siku_core',
}
