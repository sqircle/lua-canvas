package = "lua_canvas"
version = "0.1"

source = {
	url = "git://github.com/sqircle/lua_canvas.git"
}

description = {
	summary    = "A canvas like API layer on top of Cairo",
	homepage   = "http://github.com/siqrcle/lua_canvas",
	maintainer = "K-2052 <k@2052.me>",
	license    = "MIT"
}

dependencies = {
	"lua >= 5.1",
	"lgi",
}

build = {
	type = "builtin",
	modules = {
		["lua_canvas"] = "lua_canvas/init.lua",
	},
}

