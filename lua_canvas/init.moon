export lgi, Cairo, Gtk, Pango, Gdk, GdkPixbuf

lgi        = require 'lgi'
Cairo      = lgi.cairo
Gtk        = lgi.Gtk
Pango      = lgi.Pango
PangoCairo = lgi.PangoCairo
Gdk        = lgi.Gdk
GdkPixbuf  = lgi.GdkPixbuf

import Point          from require 'lua_canvas.Point'
import CanvasGradient from require 'lua_canvas.CanvasGradient'
import CanvasPattern  from require 'lua_canvas.CanvasPattern'
import RadialGradient from require 'lua_canvas.RadialGradient'
import LinearGradient from require 'lua_canvas.LinearGradient'
import Canvas         from require 'lua_canvas.Canvas'
import Context2d      from require 'lua_canvas.Context2d'

{
	:Point, :CanvasGradient, :CanvasPattern, :RadialGradient, :LinearGradient,
	:Canvas, :Context2d 
}
