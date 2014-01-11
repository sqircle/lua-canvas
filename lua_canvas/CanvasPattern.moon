class CanvasPattern
	width: 0
	height: 0
	surface: nil
	pattern: nil

  -- Expects a table with width, height and surface() attributes
	new: (obj) =>
		@width  = obj.width
		@height = obj.height

		@surface = obj\surface()
		@pattern = Cairo.pattern_create_for_surface(@surface)

{
	:CanvasPattern
}
