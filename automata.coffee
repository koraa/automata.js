Lz = window._ = require 'lazy.js'

Automata = module.exports = {}

apply = (f) ->
  (a...) ->
    f a...

Lz.Squence::deepzip = ->
  f = Lz @first()
  args = @rest().toArray()

  f args...


class Automata.Cell
  constructor: (@X, @Y, @grid, @state=0) ->

  apply: (f) ->
    @state = f @state, @

  get: (x,y) ->
    @grid.at x,y, cycl

  left:  (n=1) -> @get -n, 0
  right: (n=1) -> @get  n, 0
  up:    (n=1) -> @get 0, -n
  down:  (n=1) -> @get 0,  n

class Automata.Automat
  constructor: (@w, @h) ->
    Lz [@w, @h]
      .deepzip()
      .map apply (x,y) ->
        new Automata.Cell x, y, @
      .toArray()

  at: (x, y) ->
    if cycl
      x %= @w
      y %= @h
    @cells[x][y]

  each: (f) ->
    Lz @cells
      .flatten()
      .each (cel) -> f cel

  apply: (f) ->
    @each (cel) ->
      cel.apply f
