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
    constructor: (@state, @X, @Y, @R_proto, @dom) ->
        @visual=@state
        do @apply_cssvisual

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
        @refresh_state()
        @react R
        @apply_cssvisual()

    react: (R) ->
        @visual = R @state, @X, @Y, @

    __onclick:->
        if @click
            @tick @click

    apply_cssvisual:->
        @dom.attr 'class', 'cell state_' + @str_visual()

class CellAuto
    constructor: (@w, @h, @R=(->), @clock=1000, dstate=0) ->
        @dom = dom = $ '<div class="cell_auto"></div>'

        @cells = map [0...@h], (Y) =>
            drow = $ '<div class="row"></div>'
            dom.append drow
            map [0...@w], (X) =>
                dcell = $ '<div></div>'
                drow.append dcell
                new Cell dstate, X,Y, @R, dcell

        ($ 'body').append dom
    
    update: (x=0,y=0,w,h=(len @cells)) ->
        wQ = w?
        map (@cells[y...(y+h)]), (row)->
            w = (len row) unless wQ
            map (row[x...(x+w)]), (cell)->
                do cell.tick
            
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
    a = new CellAuto 30,30,
        rule: (i,x,y)-> (i+1)%10
        click: (i,x,y)-> (i+1)%10
