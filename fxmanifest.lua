shared_script "@ThnAC/natives.lua"
fx_version "bodacious"
game "gta5"

client_script {
	"@vrp/lib/Utils.lua",
	"cfg/config.lua",
	"client.lua"
}
server_scripts{ 
	"@vrp/lib/Utils.lua",
	"@vrp/config/Item.lua",
	"@vrp/config/Vehicle.lua",
	"cfg/config.lua",
	"server.lua"
}

ui_page "nui/index.html"
files {
	"nui/*",
	"nui/**",
	"nui/**/*"
}              