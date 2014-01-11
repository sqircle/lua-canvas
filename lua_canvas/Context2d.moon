import CanvasGradient from require 'lua_canvas.CanvasGradient'
import CanvasPattern  from require 'lua_canvas.CanvasPattern'
import LinearGradient from require 'lua_canvas.LinearGradient'
import Point          from require 'lua_canvas.Point'
import RadialGradient from require 'lua_canvas.RadialGradient'
import simpleSplit    from require 'lua_canvas.util'
rex = require 'lrex_pcre'

class Context2d
  canvas:  nil
  context: nil
  layout:  nil
  state:   nil
  states:  {}
  stateno: 0
  cache:
  weights:  'normal|bold|bolder|lighter|[1-9]00'
  styles:   'normal|italic|oblique'
  units:    'px|pt|pc|in|cm|mm|%'
  string:   '\'([^\']+)\'|"([^"]+)"|[\\w-]+'
  baselines: {'alphabetic', 'top', 'bottom', 'middle', 'ideographic', 'hanging'}
  gradient_classes: {'CanvasGradient', 'LinearGradient', 'RadialGradient'}

  -- context can come from a Gtk drawign wdiget for example.
  new: (context, canvas=nil) =>
    @context = context

    @layout = Pango.Layout.create(@context)

    transparent       = {r: 0, g: 0, b: 0, a: 1}
    transparent_black = {r: 0, g: 0, b: 0, a: 0}

    @context\set_line_width(1)

    -- State corresponds to the actual canvas API
    -- we keep the state in sync with the relevant
    -- cairo objs
    @states[@stateno] = {}
    @state = @states[@stateno]
    @state.shadowBlur      = false
    @state.shadowOffsetX   = nil 
    @state.shadowOffsetY   = nil
    @state.globalAlpha     = 1
    @state.textAlignment   = -1
    @state.fillPattern     = nil 
    @state.strokePattern   = nil
    @state.fillGradient    = nil
    @state.strokeGradient  = nil
    @state.textBaseline    = 'alphabetic'
    @state.fill            = transparent
    @state.stroke          = transparent
    @state.shadow          = transparent_black
    @state.patternQuality  = Cairo.Filter.GOOD
    @state.textDrawingMode = 'TEXT_DRAW_PATHS'
    @state.fontWeight      = Pango.Weight.NORMAL
    @state.fontStyle       = Pango.Style.NORMAL
    @state.fontSize        = 12
    @state.fontFamily      = 'sans serif'

    @setFontFromState()

  __newindex: (index, value) =>
    methodName = 'set' .. index\gsub("^%l", string.upper)

    if self[methodName] ~= nil
      self[methodName](self, value)
    else
      rawset(self, index, value)

  parseFont: (str) =>
    regexstring = '^ *' .. '(?:(' .. @weights .. ') *)?'
    regexstring .. '(?:(' .. @styles .. ') *)?' .. '([\\d\\.]+)(' .. @units .. ') *'
    regexstring .. '((?:' .. @string .. ')( *, *(?:' .. @string .. '))*)'

    fontre   = rex.new(regexstring)
    font     = {}
    captures = fontre.exec(str)

    -- Invalid
    return nil if not captures

    -- Cached
    return @cache[str] if @cache[str]

    -- Populate font object
    font.weight  = captures[2] or 'normal'
    font.style   = captures[3] or 'normal'
    font.size    = parseFloat(captures[4])
    font.unit    = captures[5]
    font.family  = rex.gsub(captures[6], '["\']/g', '')
    font.family  = simpleSplit(font.family)[1]

    --TODO: dpi
    --TODO: remaining unit conversion
    switch font.unit
      when 'pt'
        font.size /= .75
      when'in'
        font.size *= 96
      when 'mm'
        font.siz *= 96.0 / 25.4;
      when 'cm'
        font.size *= 96.0 / 2.54;

    return @cache[str] = font

  setterImageSmoothingEnabled: (val) =>
    @imageSmoothing = not not val
    @patternQuality = if val then 'best' else 'fast'

  setterTransform: (val) =>
    @resetTransform()
    @transform(val)

  setterFillStyle: (val) =>
    if type(val) == 'string'
      @setFillColor(val)
    else if type(val) == 'table'
      if @gradient_classes[val.__class.__name] or 'CanvasPattern' == val.__class.__name
        @lastFillStyle = val
        @setFillPattern(val)
      else
        return false
    else 
      return false

  setFillPattern: (obj) =>
    if @gradient_classes[obj.__class.__name]
      @state.fillGradient = obj\pattern()
    else if 'CanvasPattern' == val.__class.__name
      @state.fillPattern = obj\pattern()
    else
      return false

  getterFillStyle: () =>
    return @lastFillStyle or @fillColor

  setterStrokeStyle: (val) =>
    if type(val) == 'string'
      @setStrokeColor(val)
    else if type(val) == 'table'
      if @gradient_classes[val.__class.__name] or 'CanvasPattern' == val.__class.__name
        @lastStrokeStyle = val
        @setStrokePattern(val)
      else
        return false
    else 
      return false

  setStrokePattern: (obj) =>
    if @gradient_classes[obj.__class.__name]
      @state.strokeGradient = obj\pattern()
    else if 'CanvasPattern' == obj.__class.__name
      @state.strokePattern = obj\pattern()
    else 
      return false

  setShadowColor: (color) =>
    @state.shadow = color

  getterStrokeColor: =>
    return @state.stroke

  getterStrokeStyle: () =>
    return @lastStrokeStyle or @strokeColor

  addFont: (font) =>
    @fonts = @fonts or {}
    return if @fonts[font.name]
    @fonts[font.name] = font

  setterFont: (val) =>
    return false if not val

    if type(val) == 'string'
      font = nil
      if font = @parseFont(val)
        @lastFontString = val
        fonts = @fonts
        if fonts and fonts[font.family]
          fontObj   = fonts[font.family]
          font_type = font.weight + "-" + font.style
          fontFace  = fontObj.getFace(font_type)
          @setFontFace(fontFace, font.size)
        else
          @setFont(font.weight, font.style, font.size, font.unit, font.family)
  
  getterFont: =>
    return @lastFontString or '10px sans-serif'

  setterBaseline: (val) =>
    return if not val
    if @baselines[val]
      @lastBaseline = val
      @setTextBaseline(n)

  getterBaseline: =>
    return @lastBaseline or 'alphabetic'

  setterTextAlign: (val) =>
    switch val
      when 'center'
        @setTextAlignment(0)
        @lastTextAlignment = val
      when 'start'
        @setTextAlignment(-1)
        @lastTextAlignment = val
      when 'end':
        @setTextAlignment(1)
        @lastTextAlignment = val

  getterTextAlign: =>
    return @lastTextAlignment or 'start'

  destroy: () =>
    @context = nil
    @layout  = nil

  arc: (xc, yc, radius, startAngle, endAngle, anticlockwise=false) =>
    ctx = @context

    if anticlockwise and math.pi * 2 != angle2
      ctx\arc_negative(xc, yc, radius, startAngle, endAngle)
    else
      ctx\arc(xc, yc, radius, startAngle, endAngle)

  arcTo: (x0 ,y0, x1, y1, radius) =>
    ctx = @context
    
    -- Current point
    x,y = ctx\get_current_point()
    p0  = Point(x, y)
    
    p1  = Point(x0, y0)
    p2  = Point(x1, y1)

    if (p1.x == p0.x and p1.y == p0.y) or (p1.x == p2.x and p1.y == p2.y) or radius == 0
      ctx\line_to(p1.x, p1.y)
      return nil

    p1p0 = Point((p0.x - p1.x), (p0.y - p1.y))
    p1p2 = Point((p2.x - p1.x), (p2.y - p1.y))

    p1p0_length = math.sqrt(p1p0.x * p1p0.x + p1p0.y * p1p0.y)
    p1p2_length = math.sqrt(p1p2.x * p1p2.x + p1p2.y * p1p2.y)

    cos_phi = (p1p0.x * p1p2.x + p1p0.y * p1p2.y) / (p1p0_length * p1p2_length)

    -- all points on a line logic
    if -1 == cos_phi
      ctx\line_to(p1.x, p1.y)
      return nil
    
    if 1 == cos_phi
      -- add infinite far away point
      max_length = 65535
      factor_max = max_length / p1p0_length
      ep = Point((p0.x + factor_max * p1p0.x), (p0.y + factor_max * p1p0.y))
      ctx\line_to(ep.x, ep.y)

      return nil

    tangent     = radius / math.tan(math.acos(cos_phi) / 2)
    factor_p1p0 = tangent / p1p0_length
    t_p1p0      = Point((p1.x + factor_p1p0 * p1p0.x), (p1.y + factor_p1p0 * p1p0.y))

    orth_p1p0        = Point(p1p0.y, -p1p0.x)
    orth_p1p0_length = math.sqrt(orth_p1p0.x * orth_p1p0.x + orth_p1p0.y * orth_p1p0.y)
    factor_ra        = radius / orth_p1p0_length

    cos_alpha = (orth_p1p0.x * p1p2.x + orth_p1p0.y * p1p2.y) / (orth_p1p0_length * p1p2_length)
    if cos_alpha < 0
      orth_p1p0 = Point(-orth_p1p0.x, -orth_p1p0.y)
   
    p = Point((t_p1p0.x + factor_ra * orth_p1p0.x), (t_p1p0.y + factor_ra * orth_p1p0.y))

    orth_p1p0 = Point(-orth_p1p0.x, -orth_p1p0.y)
    sa        = math.acos(orth_p1p0.x / orth_p1p0_length)
    if orth_p1p0.y < 0
      sa = 2 * math.pi - sa

    anticlockwise = false

    factor_p1p2      = tangent / p1p2_length
    t_p1p2           = Point((p1.x + factor_p1p2 * p1p2.x), (p1.y + factor_p1p2 * p1p2.y))
    orth_p1p2        = Point((t_p1p2.x - p.x), (t_p1p2.y - p.y))
    orth_p1p2_length = math.sqrt(orth_p1p2.x * orth_p1p2.x + orth_p1p2.y * orth_p1p2.y)
    ea               = math.acos(orth_p1p2.x / orth_p1p2_length)

    ea = 2 * math.pi - ea if orth_p1p2.y < 0
    anticlockwise = true if (sa > ea) and (sa - ea) < math.pi
    anticlockwise = true if (sa < ea) and (ea - sa) > math.pi

    ctx\line_to(t_p1p0.x, t_p1p0.y)

    if anticlockwise and math.pi * 2 != radius
      ctx\arc_negative(p.x, p.y, radius, sa, ea)
    else 
      ctx\arc(p.x, p.y, radius, sa, ea)

  beginPath: () =>
    @context\new_path()

    return nil

  bezierCurveTo: (cp1x, cp1y, cp2x, cp2y, x, y) =>
    @context\curve_to(cp1x, cp1y, cp2x, cp2y, x, y)
  
  clearRect: (x, y, width, height) =>
    ctx = @context
    ctx\save()

    @savePath()

    ctx\rectangle(x, y, width, height)
    ctx\set_operator(Cairo.Operator.SOURCE)
    ctx\fill()
    @restorePath()
    ctx\restore()

    return nil

  clip: () =>
    @context\clip_preserve()
  
  closePath: () =>
    @context\close_path()

  createLinearGradient: (x0, y0, x1, y1) =>
    return LinearGradient(x0, y0, x1, y1)

  createPattern: (image, repetition) =>
    return CanvasPattern(image)

  createRadialGradient: (x0, y0, r0, x1, y1, r1) =>
    return RadialGradient(x0, y0, r0, x1, y1, r1)
  
  -- Draws an image from a filename
  drawImage: (image_filename, x=0, y=0) =>
    image = Cairo.ImageSurface.create_from_png(image_filename)
    @context\set_source_surface(image, x, y)
    @context\paint()

    return nil  

  fill: =>
    @_fill(true)

  _fill: (preserve=false) =>
    if @state.fillPattern
      @context\set_source(@state.fillPattern)
      @context\get_source()\set_extend(Cairo.Extend.REPEAT)
    else if @state.fillGradient
      Cairo.pattern.set_filter(@state.fillGradient, @state.patternQuality)
      @context\set_source(@state.fillGradient)
    else
      @setSourceRGBA(@state.fill)

    if preserve
      if @hasShadow()
        @shadow('fill_preserve')
      else
        @context\fill_preserve()
    else
      if @hasShadow()
        @shadow('fill')
      else
        @context\fill()

  fillRect: (x, y, width, height) =>
    @savePath()

    @context\rectangle(x, y, width, height)
    @fill()
    @restorePath() 

  fillText: (text, x, y) =>
    @savePath()

    if @state.textDrawingMode == 'TEXT_DRAW_GLYPHS'
      @fill()
      @setTextPath(text, x, y)
    else if @state.textDrawingMode == 'TEXT_DRAW_PATHS'
      @setTextPath(text, x, y)
      @fill()

    @restorePath()
  
  -- Returns a Gdk.pixbuf
  -- which you can then call get_pixels() on to get some pixels in a table
  getImageData: (image_filename) =>
    return GdkPixbuf.Pixbuf.new_from_file(image_filename)

  isPointInPath: (x, y) =>
    return @context\in_fill(x, y) or @context\in_stroke(x, y)

  isPointInStroke: (x, y) =>
    return @context\in_stroke(x, y)

  lineTo: (x, y) =>
    @context\line_to(x, y)
 
  moveTo: (x, y) =>
    @context\move_to(x, y)
  
  -- Takes data formatted like pixbuf\get_pixels()
  -- will also take a pixbuf
  putImageData: (imageData, width, height, rowstride=0, x=0, y=0) =>
    surface = Cairo.ImageSurface.create_for_data(imageData, Cairo.Format.ARGB24, width, height, rowstride)

    @context\set_source_surface(surface, x, y)
    @context\paint()
    return nil

  quadraticCurveTo: (x1, y1, x2, y2) =>
    ctx  = @context
    x, y = ctx\get_current_point()

    if(0 == x and 0 == y)
      x = x1
      y = y1


    curve1 = x + 2.0 / 3.0 * (x1 - x)
    curve2 = y + 2.0 / 3.0 * (y1 - y)
    curve3 = x2 + 2.0 / 3.0 * (x1 - x2)
    curve4 = y2 + 2.0 / 3.0 * (y1 - y2)

    ctx\curve_to(curve1, curve2, curve3, curve4, x2, y2)

  rect: (x, y, width, height) =>
    ctx = @context

    if width == 0
      ctx\move_to(x, y)
      ctx\line_to(x, y + height)
    else if height == 0
      ctx\move_to(x, y)
      ctx\line_to(x + width, y)
    else
      ctx\rectangle(x, y, width, height)
  
  restore: () =>
    @context\restore()
    @restoreState()

  rotate: (angle=0) =>
    @context\rotate(angle)

  save: () =>
    @context\save()
    @saveState()

    save
  
  scale: (x, y) =>
    @context\scale(x, y)
  
  saveState: () =>
    return nil if stateno == 64
    @stateno = @stateno + 1
    @states[@stateno] = {}
    
    @states[@stateno].fontFamily = @state.fontFamily
    @state = @states[@stateno]

  restoreState: () =>
    return nil if @stateno == 0 

    @states[@stateno].fontFamily = nil
    @states[@stateno]            = nil

    @stateno = @stateno - 1
    @state   = @states[@stateno]

    return @state

  stroke: (preserve) =>
    if @state.strokePattern
      @context\set_source(@state.strokePattern)
      Cairo.Pattern.set_extend(@context.get_source(), Cairo.Extend.REPEAT)
    else if @state.strokeGradient
      Cairo.Pattern.set_filter(@state.strokeGradient, @stroke.patternQuality)
      @context\set_source(@state.strokeGradient)
    else
      @setSourceRGBA(@state.stroke)

    if preserve
      if @hasShadow()
        @shadow('stroke_preserve')
      else
        @context\stroke_preserve()
    else
      if @hasShadow()
        @shadow('stroke')
      else
        @context\stroke()

  savePath: =>
    @path = @context\copy_path_flat()
    @context\new_path()

  restorePath: () =>
    @context\new_path()
    @context\append_path(@path)
    @path = nil
        
  strokeRect: (x, y, width, height) =>
    ctx = @context

    @savePath()
    ctx\rectangle(x, y, width, height)

    @stroke()
    @restorePath()        
    
  strokeText: (text, x, y) =>
    @savePath()

    if @state.textDrawingMode == 'TEXT_DRAW_GLYPHS'
      @stroke()
      @setTextPath(text, x, y)
    else if @state.textDrawingMode == 'TEXT_DRAW_PATHS'
      @setTextPath(text, x, y)
      @stroke()
  
    @restorePath()

  transform: (m11, m12, m21, m22, dx, dy) =>

    matrix = Cairo.matrix(m11, m12, m21, m22, dx, dy)
    matrix = @context\transform(matrix)

    return matrix

  translate: (x, y) =>
    @context\translate(x, y)

  setSourceRGBA: (color) =>
    @context\set_source_rgba(color.r, color.g, color.b, color.a * @state.globalAlpha)

  shadow: (shadow_type) =>
    path = @context\copy_path_flat()

    -- offset
    @context\translate(@state.shadowOffsetX, @state.shadowOffsetY)
     
    -- Apply the shadow
    @context\push_group()
    @context\new_path()
    @context\append_path(path)
    @setSourceRGBA(@state.shadow)

    @shadow_type_fn(shadow_type)

    if @state.shadowBlur
      @blur(@context\get_group_target(), @state.shadowBlur)

    -- Paint the shadow
    @context\pop_group_to_source()
    @context\paint()

    -- Restore state
    @context\restore(@context)
    @context\new_path(@context)
    @context\append_path(path)
    @shadow_type_fn(shadow_type)

    path = nil

  hasShadow: () =>
    return @state.shadow.a and (@state.shadowBlur or @state.shadowOffsetX or @state.shadowOffsetY)

  shadow_type_fn: (shadow_type) =>
    -- call the fn
    switch shadow_type
      when 'stroke_preserve'
        @context\stroke_preserve()
      when 'stroke'
        @context\stroke()
      when 'fill_preserve'
        @context\fill_preserve()
      when 'fill'
        @context\fill()
  
  -- TODO
  -- Need to convert to using a pixbuf
  blur: (surface, radius) =>
    radius  = radius - 1
    width   = surface\get_width()
    height  = surface\get_height()
    src     = surface\get_data()
    mul     =  1 / ((radius * 2) * (radius * 2))

    max_iterations = 3

    for iteration = 0, max_iterations
      for channel = 0, 4
        x,y = 0, 0
        pix = src

        for y = 0, height
          for x = 0, width
            tot = pix[0]

            tot += pre[-1]         if x > 0 
            tot += pre[-width - 1] if y > 0
            tot -= pre[-width - 1] if x > 0 and y > 0
            
            pre = tot + 2
            pix += 4

        pix = src + radius * width * 4 + radius * 4 + channel

        for y = radius, height - radius
          for x = radius, width - radius 
            l = x < if radius then 0 else x - radius
            t = y < if radius then 0 else y - radius
            r = x + radius >= if width then width - 1 else x + radius
            b = y + radius >= if height then height - 1 else y + radius

            tot = (precalc[r+b*width] + precalc[l+t*width] - precalc[l+b*width] - precalc[r+t*width])
            pix = tot * mul
            pix += 4

          pix += radius * 2 * 4

  setFontFromState: () =>
    fdesc = Pango.FontDescription()
    fdesc\set_family(@state.fontFamily)
    fdesc\set_absolute_size(@state.fontSize * Pango.SCALE)
    fdesc\set_style(@state.fontStyle)
    fdesc\set_weight(@state.fontWeight)

    @layout\set_font_description(fdesc)
    fdesc = nil
 
{
  :Context2d
}
