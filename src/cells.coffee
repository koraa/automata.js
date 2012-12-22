#
# This file contains a lib for rendering and computing
# a cellular automate for a set of rules
#
# Author: Michael Varner
# Date:   12/18/12
# File:   cells.js
#

###
@depend circle.js
@depend ../lib/jquery.js
###

#######################################################
# Data

class Cell
    constructor: (@state, @X, @Y, @R_proto, @dom, @grid) ->
        @visual=@state
        do @apply_cssvisual

        # Initial Env
        if @R_proto.init
            @tick @R_proto.init

        # Rule [event] management
        if @R_proto.rule
            @R = @R_proto.rule
        else
            @R = @R_proto

        # Click event management
        @dom.click => do @__onclick
        @click = @R_proto.click

    str_state:->
        String @state
    str_visual:->
        String @visual

    refresh_state:->
        @state = @visual
    tick:(R=@R)->
        @react R
        @apply_cssvisual()

    cnt:->
        @grid.cnt

    react: (R) ->
        @visual = R @state, @X, @Y, @, @cnt()

    __onclick:->
        if @click
            @tick @click

    apply_cssvisual:->
        @dom.attr 'class', 'cell state_' + @str_visual()

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
        @cells = map [0...@h], (Y) =>
            drow = $ '<div class="row"></div>'
            dom.append drow
            map [0...@w], (X) =>
                dcell = $ '<div></div>'
                drow.append dcell
                new Cell dstate, X,Y, @R, dcell, @
        ($ 'body').append dom
    
    each: (f, x=0,y=0,w,h=(len @cells)) ->
        wQ = w?
        map (@cells[y...(y+h)]), (row)->
            w = (len row) unless wQ
            map (row[x...(x+w)]), f
    
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
onReady ->
    a = new CellAuto 40, 40
        init: (i,x,y) ->
            (x+y)/8 %10
        rule: (i,x,y,s,n)->
            s.up 3
        click: (i) ->
            (i+1)%10
    a.start(500)
