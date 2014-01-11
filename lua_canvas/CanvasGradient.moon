class CanvasGradient
  pattern: nil

  new: (x0, y0, x1, y1) =>    
    @pattern = Cairo.Pattern.create_linear(x0, y0, x1, y1)

  -- Takes color as an RGBA table
  addColorStop: (offset, color) =>
    @pattern\add_color_stop_rgba(offset, color.r, color.g, color.b, color.a)

    return true

  destory: =>
    @pattern = nil

{
  :CanvasGradient
}
