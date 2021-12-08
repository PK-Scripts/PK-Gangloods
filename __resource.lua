resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page "html/index.html"

lua54 'yes'

client_scripts {
    'config.lua',
    'client/main.lua',
	'locale/nl.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
	'locale/nl.lua',
    'server/main.lua',
}
