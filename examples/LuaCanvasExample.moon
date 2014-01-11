lgi       = require 'lgi'
Cario     = lgi.cairo
Gtk       = lgi.Gtk
Pango     = lgi.Pango
Gdk       = lgi.Gdk
GdkPixbuf = lgi.GdkPixbuf

Context2d = require 'Context2d'

class LuaCanvasSample
  @size: 30

  new: () =>
    @window = Gtk.Window(title: 'Lua Canvas Example', on_destroy: Gtk.main_quit)
    @window\set_default_size(450, 550)
    @create_widgets()

  create_widgets: =>
    drawing_area = Gtk.DrawingArea{
      on_draw: (drawing, cr) ->
        @on_draw(drawing, cr)
    }
    @window\add(drawing_area)

  show_all: =>
    @window\show_all()

  on_draw: (drawing, cr) =>
    ctx = Context2d(cr)
    ctx\beginPath()
    ctx\lineTo(50, 102)
    ctx\lineTo(50 + 100, 102)
    ctx\stroke()

cairo_sample = LuaCanvasSample()
cairo_sample\show_all()
Gtk.main()
