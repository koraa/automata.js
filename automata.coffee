Lz = window.Lz = require 'lazy.js'
$  = window.$  = require 'jquery'
window._ = require 'lodash'

Automata = module.exports = {}

Automata.apply = apply = (f) ->
  (a) ->
    f a...

Automata.smod = smod = (x, m) ->
  if x < 0
    m - (-x) % m
  else
    x % m

window.cartesian = (a, b) ->
  r = []
  for m in a
    for k in b
      r.push [m,k]
  r

class Automata.Cell
  constructor: (@X, @Y, @grid, @state=0) ->

  apply: (f) ->
    @nu = f @state, @

  blip: =>
    @state = @nu

  get: (x,y) ->
    @grid.at @X+x,@Y+y

  left:  (n=1) -> @get -n, 0
  right: (n=1) -> @get  n, 0
  up:    (n=1) -> @get 0, -n
  down:  (n=1) -> @get 0,  n

class Automata.Automat
  constructor: (@w, @h) ->
    @cells =
      for x in [0..@w]
        for y in [0..@h]
          new Automata.Cell x, y, @

  at: (x, y) ->
    @cells[smod x, @w][smod y, @h]

  each: (f) ->
    Lz @cells
      .flatten()
      .each f

  blip: => @each (cel) -> cel.blip()

  apply: (f) ->
    @each (cel) -> cel.apply f

  update: (f) =>
    @apply f
    @blip()

class Automata.PixelCanvas
  constructor: (@canvas, @W, @H) ->
    @g = @canvas.getContext "2d"
  
  clear: (color=0)->
    @g.fillStyle = color
    @g.fillRect 0, 0, @canvas.width, @canvas.height

  px: (x,y, color=0) ->
    @g.fillStyle = color
    pxW = @canvas.width / @W
    pxH = @canvas.height / @H
    @g.fillRect pxW*x, pxH*y, pxW, pxH

class Automata.CanvasRenderer extends Automata.PixelCanvas
  stdColors = ["black", "green", "brown", "red", "orange", "yellow", "white"]

  constructor: (canvas, @colors=stdColors) ->
    super canvas

  render: (automat) ->
    @W = automat.w
    @H = automat.h
    @clear()
    automat.each (cell) =>
      @px cell.X, cell.Y, @colors[cell.state] || cell.state
