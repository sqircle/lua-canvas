import simpleSplit from require 'lua_canvas.util'

describe 'lua_canvas.util', ->
	it 'should split a string with commas', ->
		tokens = simpleSplit('cats,   dogs  ')

		assert.are.same(tokens, {'cats', 'dogs'})
