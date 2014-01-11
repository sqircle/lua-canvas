test::
	busted -p _spec.moon$

local: build
	luarocks make --local lua_canvas.rockspec

global: build
	sudo luarocks make lua_canvas.rockspec

build::
	moonc lua_canvas

watch:: build
	moonc -w lua_canvas
