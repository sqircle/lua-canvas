lua_canvas = require 'lua_canvas'
import Canvas from lua_canvas

describe 'lua_canvas.canvas', -> 
  it 'should return the canvas type', ->
    canvas = Canvas(10, 10)
    assert.equal('image', canvas.canvas_type)

  it 'should return false when the context type does not exist', ->
    assert.equal(false, Canvas(200, 300)\getContext('invalid'))
 
  it 'should return a context', ->
    canvas = Canvas(100, 200)
    ctx    = canvas\getContext('2d')
    assert(ctx.__class.__name == 'Context2d')

  it 'should init a canvas with correct width and height', ->
    canvas = Canvas(100, 200)
    assert.equal(100, canvas.width)
    assert.equal(200, canvas.height)

    canvas = Canvas(0, 0)
    assert.equal(0, canvas.width)
    assert.equal(0, canvas.height)

    canvas.width  = 50
    canvas.height = 5
    assert.equal(50, canvas.width)
    assert.equal(5, canvas.height)

  it 'should init a surface', ->
    canvas = Canvas(100, 200)
    assert.equal(100, canvas.surface\get_width())
    assert.equal(200, canvas.surface\get_height())
  