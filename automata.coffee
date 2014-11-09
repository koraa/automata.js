Lz = window.Lz = require 'lazy.js'
$  = window.$  = require 'jquery'

Automata = module.exports = {}

Automata.apply = apply = (f) ->
  (a) ->
    f a...

Automata.smod = smod = (x, m) ->
  if x < 0
    m - (-x) % m
  else
    x % m

Automata.cross = cross = (aV,bV) ->
  r = []
  for a in aV
    for b in bV
      r.push [a, b]
  r

class Automata.Cell
  constructor: (@X, @Y, @grid, @state=0) ->

  apply: (f) =>
    @nu = f @state, @
  blip: =>
    @state = @nu

  get: (x,y) =>
    @grid.at @X+x,@Y+y

  left:  (n=1) => @get -n, 0
  right: (n=1) => @get  n, 0
  up:    (n=1) => @get 0, -n
  down:  (n=1) => @get 0,  n

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
      .each (cel) -> f cel

  apply: (f) ->
    @each (cel) ->
      cel.apply f
    @each (cel) ->
      cel.blip()

class Automata.PixelCanvas
  constructor: (@canvas, @W, @H) ->

  px: (x,y, color=0) ->
    g = @canvas.getContext "2d"
    g.fillStyle = color

    pxW = @canvas.width / @W
    pxH = @canvas.height / @H
    g.fillRect pxW*x, pxH*y, pxW, pxH

class Automata.CanvasRenderer extends Automata.PixelCanvas
  stdColors = ["black", "brown", "red", "orange", "yellow", "white"]

  constructor: (canvas, @colors=stdColors) ->
    super canvas

  render: (automat) ->
    @W = automat.w
    @H = automat.h
    automat.each (cell) =>
      @px cell.X, cell.Y, @colors[cell.state] || cell.state
