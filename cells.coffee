#
# This file contains a lib for rendering and computing
# a cellular automate for a set of rules
#
# Author: Karolin Varner
# Date:   12/18/12
# File:   cells.js
#

#######################################################
# Data

class Cell
  constructor: (@inistate, @X, @Y, @R_stt, @dom, @grid) ->
    # Click event management
    @dom.click => do @__onclick

  #####################################
  # PROPS

  str_state:->
    String @state
  str_visual:->
    String @visual

  cnt:->
    @grid.cnt

  ######################################
  # RULES
  

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

  

  ###############################
  # Rendering

  apply_cssvisual:->
    @dom.attr 'class', 'cell state_' + @str_visual()
  render: @apply_cssvisual

  ###############################
  # Relative gridacc

  relm: (x=0,y=0, cyclic=true)->
    _ = cyclat @grid.cells, @Y+y, cyclic
    if _
      cyclat _, @X+x, cyclic
  relms: (x,y, cyclic=true)->
    _ = (@relm x,y,cyclic)
    _.state if _

  left: (l=1, cyclic=true)->
    @relms -l, 0, cyclic
  right: (l=1, cyclic=true)->
    @relms l, 0, cyclic
  up: (l=1, cyclic=true)->
    @relms 0, -l, cyclic
  down: (l=1, cyclic=true)->
    @relms 0, l, cyclic


class CellAuto
  constructor: (@w, @h, @R=(->), @clock=1000, dstate=0) ->
    @cnt = 0

    @dom = dom = $ '<div class="cell_auto"></div>'
    @cells = _.map [0...@h], (Y) =>
      drow = $ '<div class="row"></div>'
      dom.append drow
      _.map [0...@w], (X) =>
        dcell = $ '<div></div>'
        drow.append dcell
        new Cell dstate, X,Y, @R, dcell, @
    ($ 'body').append dom
  
  each: (f, x=0,y=0,w,h=(len @cells)) ->
    wQ = w?
    _.map (@cells[y...(y+h)]), (row)->
      w = (len row) unless wQ
      _.map (row[x...(x+w)]), f
  
  update: (x=0,y=0,w,h=(len @cells)) ->
    @cnt++
    @each (cell) -> do cell.refresh_state
    @each (cell) -> do cell.tick

  step:->
    do @update
  start: (@clock=@clock)->
    @runner = setInterval (=>@update()), @clock
  stop: ->
    clearInterval(@runner) if @runner
    @runner = 0
  set_clock: (@clock) ->
    if (@runner)
      do @stop
      do @start

##########################
# TEST

a = null
($ document).ready ->
  a = new CellAuto 40, 40,
    init: (i,x,y) ->
      x/3 % 4
    rule: (i,x,y,s,n)->
      s.right 3
    click: (i) ->
      (i+1)%10
  a.start(500)
