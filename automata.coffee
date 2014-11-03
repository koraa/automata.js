# This is not really common
$ = window.$ = require 'jquery'
_ = window._ = require 'lodash'

Automata = module.exports = {}

class Automata.Cell
  constructor: (@inistate, @X, @Y, @R, @dom, @grid) ->
    @reset()
    @dom.click => do @__onclick

  # PROP ##################

  cnt:->
    @grid.cnt

  # RULES #################

  react: (R) ->
    if R.rule
      R = R.rule
    @visual = R @state, @X, @Y, @, @cnt()

  refresh_state:->
    @state = @visual


  tick:(R=@R)->
    @react R
    if (@state != @visual)
      @apply_cssvisual()
  ttick: (R)->
    if R
      @tick R

  __onclick:->
    @ttick @R.click
  reset:->
    @visual = @state = @initstate
    @ttick @R.init
    do @apply_cssvisual

  # Rendering ################

  apply_cssvisual:->
    @dom.attr 'class', "cell state_#{@visual}"
  render: @apply_cssvisual

  # Relative grid links ######

  relm: (x=0,y=0, cyclic=true)->
    ysum = @Y + y
    if cyclic
      ysum = ysum % @grid.cells.length

    row = @grid.cells[ysum]

    if not row
      console.log("ysum(#{@Y}, #{y}, #{@grid.cells.length}, #{cyclic}) = #{ysum} ==> #{row}")
      return row

    xsum = @X + x
    if cyclic
      xsum = xsum % row.length

    cell = row[xsum]
    if not cell
      console.log("xsum(#{@X}, #{x}, #{row.length}, #{cyclic}) = #{xsum} ==> #{cell}")
    cell

  relms: (x,y, cyclic=true)->
    cell = @relm x,y,cyclic
    cell && cell.state

  left: (l=1, cyclic=true)->
    @relms -l, 0, cyclic
  right: (l=1, cyclic=true)->
    @relms l, 0, cyclic
  up: (l=1, cyclic=true)->
    @relms 0, -l, cyclic
  down: (l=1, cyclic=true)->
    @relms 0, l, cyclic


class Automata.Automat
  constructor: (@w, @h, @R=(->), @clock=1000, dstate=0) ->
    @cnt = 0

    @dom = dom = $ '<div class="cell_auto"></div>'
    @cells = _.map [0...@h], (Y) =>
      drow = $ '<div class="row"></div>'
      dom.append drow
      _.map [0...@w], (X) =>
        dcell = $ '<div class="cell"></div>'
        drow.append dcell
        new Automata.Cell dstate, X,Y, @R, dcell, @
    ($ 'body').append dom
  
  each: (f, x=0,y=0,w,h=@cells.length) ->
    wQ = w?
    _.map (@cells[y...(y+h)]), (row)->
      w = row.length unless wQ
      _.map (row[x...(x+w)]), f
  
  update: (x=0,y=0,w,h=@cells.length) ->
    @cnt++
    @each (cell) => cell.refresh_state()
    @each (cell) => cell.tick()

  start: (@clock=@clock)->
    @runner = setInterval (=> do @update), @clock

  stop: ->
    if @runner
      clearInterval(@runner)
    @runner = 0

  set_clock: (@clock) ->
    if (@runner)
      do @stop
      do @start

