class Canvas
	width: nil
	height: nil
	canvas_type: nil
	surface: nil

	new: (width, height, canvas_type='image') =>
		@width       = width
		@height      = height
		@canvas_type = canvas_type

		switch @canvas_type
			when 'image'
				@surface = cairo.ImageSurface.create('ARGB32', @width, @height)

	destroy: () =>
		@surface.destroy()
