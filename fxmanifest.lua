fx_version 'adamant'

game 'gta5'

version '1.0.1'

ui_page "nui/meter.html"

files {
	"nui/digital-7.regular.ttf",
	"nui/OPTICalculator.otf",
	"nui/meter.html",
	"nui/meter.css",
	"nui/meter.js",
	'nui/img/phone.png',
	'nui/img/fare1.png',
	'nui/img/fare2.png',
	'nui/img/redlight.png',
	'nui/img/greenlight.png',
	'nui/img/offlight.png',
}

client_scripts{
  'config.lua',
  'client/main.lua'
}

server_scripts{
  'config.lua',
  'server/main.lua'
}
