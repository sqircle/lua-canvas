lua_canvas = require 'lua_canvas'
import RadialGradient from lua_canvas

describe 'lua_canvas.RadialGradient', -> 
	it 'should create a RadialGradient', ->
		gradient = RadialGradient(1, 1, 19, 1)

		assert(gradient.__class.__name == 'RadialGradient')
		assert.true(gradient\addColorStop(0, {r: 255, g: 0, b: 0, a: 0}))
		assert.true(gradient\addColorStop(1, {r: 255, g: 0, b: 0, a: 0}))
