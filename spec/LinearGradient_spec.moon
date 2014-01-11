lua_canvas = require 'lua_canvas'
import LinearGradient from lua_canvas

describe 'lua_canvas.LinearGradient', -> 
	it 'should create a LinearGradient', ->
		gradient = LinearGradient(1, 1, 19, 1)

		assert(gradient.__class.__name == 'LinearGradient')
		assert.true(gradient\addColorStop(0, {r: 255, g: 0, b: 0, a: 0}))
		assert.true(gradient\addColorStop(1, {r: 255, g: 0, b: 0, a: 0}))
