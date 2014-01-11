lua_canvas = require 'lua_canvas.Point'
import Point from lua_canvas

describe 'lua_canvas.Point', -> 
	it 'should create a new point', ->
		point = Point(1, 5)

		assert.equal(point.x, 1)
		assert.equal(point.y, 5)
