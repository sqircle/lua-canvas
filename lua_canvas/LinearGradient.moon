import CanvasGradient from require 'lua_canvas.CanvasGradient'

class LinearGradient extends CanvasGradient
	new: (x0, y0, x1, y1) =>
		@pattern = Cairo.Pattern.create_linear(x0, y0, x1, y1)

{
	:LinearGradient
}
