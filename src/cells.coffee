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
    constructor: (@state, @X, @Y, @R, @dom) ->
        @visual=@state
        do @apply_cssvisual

    str_state:->
        String @state
    str_visual:->
        String @visual

    refresh_state:->
        @state = @visual
    tick:->
        do @refresh_state
        do @react
        do @apply_cssvisual

    apply_rule: (R) ->
        @visual = R @state, @X, @Y, @
    react:->
        @apply_rule @R

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
                new Cell dstate, X,Y, ((a...) => @R a...), dcell

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
