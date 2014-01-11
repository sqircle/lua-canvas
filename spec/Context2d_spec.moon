describe 'lua_canvas.context2d', ->
  it 'should serialize some colors', ->
  	canvas = Canvas(200, 200)
    ctx    = canvas.getContext('2d')

    for prop in {'fillStyle', 'strokeStyle', 'shadowColor'}
      ctx[prop] = "#FFFFFF"
      assert.equal "#ffffff", ctx[prop], prop + " #FFFFFF -> #ffffff, got " + ctx[prop]

      ctx[prop] = "#FFF"
      assert.equal "#ffffff", ctx[prop], prop + " #FFF -> #ffffff, got " + ctx[prop]

      ctx[prop] = "rgba(128, 200, 128, 1)"
      assert.equal "#80c880", ctx[prop], prop + " rgba(128, 200, 128, 1) -> #80c880, got " + ctx[prop]

      ctx[prop] = "rgba(128,80,0,0.5)"
      assert.equal "rgba(128, 80, 0, 0.50)", ctx[prop], prop + " rgba(128,80,0,0.5) -> rgba(128, 80, 0, 0.5), got " + ctx[prop]
     
      ctx[prop] = "rgba(128,80,0,0.75)"
      assert.equal "rgba(128, 80, 0, 0.75)", ctx[prop], prop + " rgba(128,80,0,0.75) -> rgba(128, 80, 0, 0.75), got " + ctx[prop]
      
      break if "shadowColor" is prop

      grad      = ctx.createLinearGradient(0, 0, 0, 150)
      ctx[prop] = grad
      assert.are.same(grad, ctx[prop])

  it 'should parse a font string', ->
    tests = {
      '20px Arial', { size: 20, unit: 'px', family: 'Arial' }, 
      '20pt Arial', { size: 26.666666666666668, unit: 'pt', family: 'Arial' }, 
      '20.5pt Arial', { size: 27.333333333333332, unit: 'pt', family: 'Arial' }, 
      '20% Arial', { size: 20, unit: '%', family: 'Arial' }, 
      '20mm Arial', { size: 75.59055118110237, unit: 'mm', family: 'Arial' }, 
      '20px serif', { size: 20, unit: 'px', family: 'serif' }, 
      '20px sans-serif', { size: 20, unit: 'px', family: 'sans-serif' }, 
      '20px monospace', { size: 20, unit: 'px', family: 'monospace' }, 
      '50px Arial, sans-serif', { size: 50, unit: 'px', family: 'Arial, sans-serif' }, 
      'bold italic 50px Arial, sans-serif', { style: 'italic', weight: 'bold', size: 50, unit: 'px', family: 'Arial, sans-serif' }, 
      '50px Helvetica ,  Arial, sans-serif', { size: 50, unit: 'px', family: 'Helvetica ,  Arial, sans-serif' },
      '50px "Helvetica Neue", sans-serif', { size: 50, unit: 'px', family: 'Helvetica Neue, sans-serif' }, 
      '50px "Helvetica Neue", "foo bar baz" , sans-serif', { size: 50, unit: 'px', family: 'Helvetica Neue, foo bar baz , sans-serif' },
      "50px 'Helvetica Neue'", { size: 50, unit: 'px', family: "Helvetica Neue" }, 
      'italic 20px Arial', { size: 20, unit: 'px', style: 'italic', family: 'Arial' }, 
      'oblique 20px Arial', { size: 20, unit: 'px', style: 'oblique', family: 'Arial' }, 
      'normal 20px Arial', { size: 20, unit: 'px', style: 'normal', family: 'Arial' }, 
      '300 20px Arial', { size: 20, unit: 'px', weight: '300', family: 'Arial' }, 
      '800 20px Arial', { size: 20, unit: 'px', weight: '800', family: 'Arial' }, 
      'bolder 20px Arial', { size: 20, unit: 'px', weight: 'bolder', family: 'Arial' }, 
      'lighter 20px Arial', { size: 20, unit: 'px', weight: 'lighter', family: 'Arial' }
    }
  
    for key, value in tests
      str    = value
      obj    = tests[key + 1]
      actual = Canvas.parseFont(str)
  
      assert.are.same(actual, obj)
  
  it 'should parse colors', ->
    canvas = nCanvas(200, 200)
    ctx    = canvas.getContext("2d")
  
    ctx.fillStyle = "#ffccaa"
    assert.equal "#ffccaa", ctx.fillStyle
  
    ctx.fillStyle = "#FFCCAA"
    assert.equal "#ffccaa", ctx.fillStyle
  
    ctx.fillStyle = "#FCA"
    assert.equal "#ffccaa", ctx.fillStyle
  
    ctx.fillStyle = "#fff"
    ctx.fillStyle = "#FGG"
    assert.equal "#ff0000", ctx.fillStyle
  
    ctx.fillStyle = "#fff"
    ctx.fillStyle = "afasdfasdf"
    assert.equal "#ffffff", ctx.fillStyle
  
    ctx.fillStyle = "rgb(255,255,255)"
    assert.equal "#ffffff", ctx.fillStyle
  
    ctx.fillStyle = "rgb(0,0,0)"
    assert.equal "#000000", ctx.fillStyle
  
    ctx.fillStyle = "rgb( 0  ,   0  ,  0)"
    assert.equal "#000000", ctx.fillStyle
  
    ctx.fillStyle = "rgba( 0  ,   0  ,  0, 1)"
    assert.equal "#000000", ctx.fillStyle
  
    ctx.fillStyle = "rgba( 255, 200, 90, 0.5)"
    assert.equal "rgba(255, 200, 90, 0.50)", ctx.fillStyle
  
    ctx.fillStyle = "rgba( 255, 200, 90, 0.75)"
    assert.equal "rgba(255, 200, 90, 0.75)", ctx.fillStyle
  
    ctx.fillStyle = "rgba( 255, 200, 90, 0.7555)"
    assert.equal "rgba(255, 200, 90, 0.75)", ctx.fillStyle
  
    ctx.fillStyle = "rgba( 255, 200, 90, .7555)"
    assert.equal "rgba(255, 200, 90, 0.75)", ctx.fillStyle
  
    ctx.fillStyle = "rgb(0, 0, 9000)"
    assert.equal "#0000ff", ctx.fillStyle
  
    ctx.fillStyle = "rgba(0, 0, 0, 42.42)"
    assert.equal "#000000", ctx.fillStyle
  
  it 'should set patternQuality', ->
    canvas = Canvas(200, 200)
    ctx    = canvas\getContext('2d')
  
    assert.equal('good', ctx.patternQuality)
    ctx.patternQuality = 'best'
    assert.equal('best', ctx.patternQuality)
    ctx.patternQuality = 'invalid'
    assert.equal('best', ctx.patternQuality)
  
  it 'should set a font', ->
    canvas = Canvas(200, 200)
    ctx    = canvas.getContext('2d')
  
    assert.equal('10px sans-serif', ctx.font)
    ctx.font = '15px Arial, sans-serif'
    assert.equal('15px Arial, sans-serif', ctx.font)
  
  it 'should set line width', ->
    canvas = Canvas(200, 200)
    ctx    = canvas\getContext('2d')
  
    ctx.lineWidth = 10.0
    assert.equal(10, ctx.lineWidth)
  
    ctx.lineWidth = -5
    assert.equal(10, ctx.lineWidth)
  
    ctx.lineWidth = 0
    assert.equal(10, ctx.lineWidth)
  
    ctx.lineWidth = 2
    assert.equal(2, ctx.lineWidth)
  
  it 'should set antialias', ->
    canvas = Canvas(200, 200)
    ctx    = canvas\getContext('2d')
  
    assert.equal('default', ctx.antialias)
  
    ctx.antialias = 'none'
    assert.equal('none', ctx.antialias)
  
    ctx.antialias = 'gray'
    assert.equal('gray', ctx.antialias)
  
    ctx.antialias = 'subpixel'
    assert.equal('subpixel', ctx.antialias)
  
    ctx.antialias = 'invalid'
    assert.equal('subpixel', ctx.antialias)
  
    ctx.antialias = 1
    assert.equal('subpixel', ctx.antialias)
  
  it 'should set a lineCape', ->
    canvas = Canvas(200, 200)
    ctx    = canvas\getContext('2d')
  
    assert.equal('butt', ctx.lineCap)
  
    ctx.lineCap = 'round'
    assert.equal('round', ctx.lineCap)
  
  it 'should set a lineJoin', ->
    canvas = Canvas(200, 200)
    ctx    = canvas\getContext('2d')
  
    assert.equal('miter', ctx.lineJoin)
  
    ctx.lineJoin = 'round'
    assert.equal('round', ctx.lineJoin)
  
  it 'should set the globalAlpha', ->
    assert.equal(1, ctx.globalAlpha)
  
    ctx.globalAlpha = 0.5
    assert.equal(0.5, ctx.globalAlpha)
  
  it 'should check isPointInPath', ->
    ctx.rect(5,5,100,100)
    ctx.rect(50,100,10,10)
  
    assert(ctx.isPointInPath(10,10))
    assert(ctx.isPointInPath(10,50))
    assert(ctx.isPointInPath(100,100))
    assert(ctx.isPointInPath(105,105))
    assert(!ctx.isPointInPath(106,105))
    assert(!ctx.isPointInPath(150,150))
  
    assert(ctx.isPointInPath(50,110))
    assert(ctx.isPointInPath(60,110))
    assert(!ctx.isPointInPath(70,110))
    assert(!ctx.isPointInPath(50,120))
  
  it 'should set textAlign', ->
    assert.equal('start', ctx.textAlign)
    ctx.textAlign = 'center'
  
    assert.equal('center', ctx.textAlign)
    ctx.textAlign = 'right'
  
    assert.equal('right', ctx.textAlign)
  
    ctx.textAlign = 'end'
    assert.equal('end', ctx.textAlign)
  
    ctx.textAlign = 'fail'
    assert.equal('end', ctx.textAlign)
  
  it 'should create imageData', ->
    imageData = ctx\createImageData(2,6)
    assert.equal(2, imageData.width)
    assert.equal(6, imageData.height)
    assert.equal(2 * 6 * 4, imageData.data.length)
  
    assert.equal(0, imageData.data[0])
    assert.equal(0, imageData.data[1])
    assert.equal(0, imageData.data[2])
    assert.equal(0, imageData.data[3])
  
  it 'should measure text', ->
    assert(ctx\measureText('foo').width)
    assert(ctx\measureText('foo').width != ctx\measureText('foobar').width)
    assert(ctx\measureText('foo').width != ctx\measureText('  foo').width)
  
  it 'should getImageData', ->
    ctx.fillStyle = '#f00'
    ctx.fillRect(0,0,1,6)
  
    ctx.fillStyle = '#0f0'
    ctx.fillRect(1,0,1,6)
  
    ctx.fillStyle = '#00f'
    ctx.fillRect(2,0,1,6)
  
    -- Full width
    imageData = ctx\getImageData(0,0,3,6)
    assert.equal(3, imageData.width)
    assert.equal(6, imageData.height)
    assert.equal(3 * 6 * 4, imageData.data.length)
  
    assert.equal(255, imageData.data[0])
    assert.equal(0, imageData.data[1])
    assert.equal(0, imageData.data[2])
    assert.equal(255, imageData.data[3])
  
    assert.equal(0, imageData.data[4])
    assert.equal(255, imageData.data[5])
    assert.equal(0, imageData.data[6])
    assert.equal(255, imageData.data[7])
  
    assert.equal(0, imageData.data[8])
    assert.equal(0, imageData.data[9])
    assert.equal(255, imageData.data[10])
    assert.equal(255, imageData.data[11])
  
    -- Slice
    imageData = ctx\getImageData(0,0,2,1)
    assert.equal(2, imageData.width)
    assert.equal(1, imageData.height)
    assert.equal(8, imageData.data.length)
  
    assert.equal(255, imageData.data[0])
    assert.equal(0,   imageData.data[1])
    assert.equal(0,   imageData.data[2])
    assert.equal(255, imageData.data[3])
  
    assert.equal(0,   imageData.data[4])
    assert.equal(255, imageData.data[5])
    assert.equal(0,   imageData.data[6])
    assert.equal(255, imageData.data[7])
  
    -- Assignment
    data = ctx\getImageData(0,0,5,5).data
    data[0] = 50
    assert.equal(50, data[0])
    data[0] = 280
    assert.equal(255, data[0])
    data[0] = -4444
    assert.equal(0, data[0])
  
  it 'should create a pattern using canvas', ->
    pattern  = Canvas(2, 2)
    checkers = pattern\getContext("2d")
    
    -- white
    checkers.fillStyle = "#fff"
    checkers.fillRect 0, 0, 2, 2
    
    -- black
    checkers.fillStyle = "#000"
    checkers.fillRect 0, 0, 1, 1
    checkers.fillRect 1, 1, 1, 1
    imageData = checkers\getImageData(0, 0, 2, 2)
    assert.equal 2, imageData.width
    assert.equal 2, imageData.height
    assert.equal 16, imageData.data.length
    
    -- (0,0) black
    assert.equal 0, imageData.data[0]
    assert.equal 0, imageData.data[1]
    assert.equal 0, imageData.data[2]
    assert.equal 255, imageData.data[3]
    
    -- (1,0) white
    assert.equal 255, imageData.data[4]
    assert.equal 255, imageData.data[5]
    assert.equal 255, imageData.data[6]
    assert.equal 255, imageData.data[7]
    
    -- (0,1) white
    assert.equal 255, imageData.data[8]
    assert.equal 255, imageData.data[9]
    assert.equal 255, imageData.data[10]
    assert.equal 255, imageData.data[11]
    
    -- (1,1) black
    assert.equal 0, imageData.data[12]
    assert.equal 0, imageData.data[13]
    assert.equal 0, imageData.data[14]
    assert.equal 255, imageData.data[15]
  
    canvas  = Canvas(20, 20)
    ctx     = canvas\getContext("2d")
  
    pattern       = ctx\createPattern(pattern)
    ctx.fillStyle = pattern
    ctx.fillRect 0, 0, 20, 20
  
    imageData = ctx\getImageData(0, 0, 20, 20)
    assert.equal 20, imageData.width
    assert.equal 20, imageData.height
    assert.equal 1600, imageData.data.length
  
    i = 0
    b = true
    while i < imageData.data.length
      if b
        assert.equal 0,   imageData.data[i++]
        assert.equal 0,   imageData.data[i++]
        assert.equal 0,   imageData.data[i++]
        assert.equal 255, imageData.data[i++]
      else
        assert.equal 255, imageData.data[i++]
        assert.equal 255, imageData.data[i++]
        assert.equal 255, imageData.data[i++]
        assert.equal 255, imageData.data[i++]
      
      -- alternate b, except when moving to a new row
      b = (if i % (imageData.width * 4) == 0 then b else not b)
  
  it 'should create a pattern from an image', ->
    img     = Canvas.Image()
    img.src = __dirname + "/fixtures/checkers.png"
    
    canvas = Canvas(20, 20)
    ctx    = canvas\getContext("2d")
  
    pattern       = ctx\createPattern(img)
    ctx.fillStyle = pattern
  
    ctx.fillRect 0, 0, 20, 20
    imageData = ctx\getImageData(0, 0, 20, 20)
  
    assert.equal 20, imageData.width
    assert.equal 20, imageData.height
    assert.equal 1600, imageData.data.length
  
    i = 0
    b = true
    while i < imageData.data.length
      if b
        assert.equal 0,   imageData.data[i++]
        assert.equal 0,   imageData.data[i++]
        assert.equal 0,   imageData.data[i++]
        assert.equal 255, imageData.data[i++]
      else
        assert.equal 255, imageData.data[i++]
        assert.equal 255, imageData.data[i++]
        assert.equal 255, imageData.data[i++]
        assert.equal 255, imageData.data[i++]
      
      -- alternate b, except when moving to a new row
      b = (if i % (imageData.width * 4) == 0 then b else not b)
  
   it 'should create a linear gradient', ->
     canvas = Canvas(20, 1)
     ctx    = canvas\getContext("2d")
  
     gradient = ctx\createLinearGradient(1, 1, 19, 1)
     gradient.addColorStop 0, "#fff"
     gradient.addColorStop 1, "#000"
  
     ctx.fillStyle = gradient
     ctx.fillRect 0, 0, 20, 1
  
     imageData = ctx\getImageData(0, 0, 20, 1)
     assert.equal 20, imageData.width
     assert.equal 1,  imageData.height
     assert.equal 80, imageData.data.length
     
     -- (0,0) white
     assert.equal 255, imageData.data[0]
     assert.equal 255, imageData.data[1]
     assert.equal 255, imageData.data[2]
     assert.equal 255, imageData.data[3]
     
     -- (20,0) black
     i = imageData.data.length - 4
     assert.equal 0,   imageData.data[i + 0]
     assert.equal 0,   imageData.data[i + 1]
     assert.equal 0,   imageData.data[i + 2]
     assert.equal 255, imageData.data[i + 3]
   