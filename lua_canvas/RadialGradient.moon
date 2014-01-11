import CanvasGradient from require 'lua_canvas.CanvasGradient'

class RadialGradient extends CanvasGradient
	new: (x0, y0, r0, x1, y1, r1) =>
		@pattern = Cairo.Pattern.create_radial(x0, y0, r0, x1, y1, r1)

{
	:RadialGradient
}
