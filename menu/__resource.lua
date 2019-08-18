--resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'
resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "ui/index.html"

-- Client Scripts
client_scripts {
		"config.lua",
		"client/client.lua",
}

server_scripts {
		"config.lua",
		'@mysql-async/lib/MySQL.lua',
		"server/server.lua",
}

files {
	"ui/index.html",
	"ui/fonts/Circular-Bold.ttf",
	"ui/fonts/Circular-Book.ttf",
	"ui/assets/cursor.png",
	"ui/assets/close.png",
	"ui/front.js",
	"ui/script.js",
	"ui/style.css",
	'ui/debounce.min.js',
	'ui/sounds/lock.ogg',
	'ui/sounds/unlock.ogg'
}
