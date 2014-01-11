import Context2d from require 'lua_canvas.Context2d'

class Canvas
  width:       nil
  height:      nil
  canvas_type: nil
  surface:     nil
  context:   nil

  new: (width, height, canvas_type='image') =>
    @width       = width
    @height      = height
    @canvas_type = canvas_type
    @getContext()

    switch @canvas_type
      when 'image'
        @surface = Cairo.ImageSurface.create('ARGB32', @width, @height)
  
  destroy: () =>
    @surface\finish()
    @surface = nil
    @context\destroy()
    @context = nil
  
  resurface: () =>
    switch @canvas_type
      when 'image'
        old_width  = @surface\get_width()
        old_height = @surface\get_height()
        
        -- Destroy surface
        @surface\finish()
        @surface = nil
        
        -- Create a new one
        @surface = Cairo.ImageSurface.create('ARGB32', @width, @height)
    
        -- Reset Context
        prev_context = @context.context

        @context\destroy()
        @context = nil
        @getContext('2d', prev_context)

  data: () =>
    return @surface\get_data()
  
  stride: () =>
    return @surface\get_stride()

  setWidth: (width) =>
    @width = width
    @resurface()

  setHeight: (height) =>
    @height = height
    @resurface()

  getContext: (contextId, prev_context=nil) =>
    if '2d' == contextId
      if prev_context
        @context = Context2d(prev_context, self)
      else if not @context
        @context = Context2d(Cairo.Context.create(@surface), self)
        
      return @context
    else
      return false

{
  :Canvas
}
