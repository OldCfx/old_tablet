fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name "old_tablet"
description "tablet interface"
author "OldMoney"
version "1.0.0"

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}


ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script.js',
	'html/style.css'
}
