lua_canvas = require 'lua_canvas'
import CanvasGradient from lua_canvas
inspect = require 'inspect'

describe 'lua_canvas.CanvasGradient', -> 
	it 'should create a GanvasGradient', ->
		gradient = CanvasGradient(1, 1, 19, 1)

		assert(gradient.__class.__name == 'CanvasGradient')

		assert.true(gradient\addColorStop(0, {r: 255, g: 0, b: 0, a: 0}))
		assert.true(gradient\addColorStop(1, {r: 255, g: 0, b: 0, a: 0}))
