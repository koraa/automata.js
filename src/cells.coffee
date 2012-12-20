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
        do @apply_class
        do @apply_pos

    str_state:->
        String @state

    apply_rule: (R) ->
        @state = R @state, [@X, @Y], @
    react:->
        apply_rule @R

    apply_class:->
        @dom.attr 'class', 'cell ' + @str_state()

    apply_pos:->
        @dom.css "left", @X,
                 "top",  @Y,
                 "width",  "2px",
                 "height", "2px"

gen_grid = (w, h, R, dstate=0) ->
    flog "CALLD", w,h,R,dstate
    cauto = $ '<div class="cell_auto"></div>'

    map [0...h], (Y) ->
        drow = $ '<div class="row"></div>'
        map [0...w], (X) ->
            dcell = $ '<div></div>'
            new Cell dstate, X,Y, R, dcell

            drow.append dcell
        cauto.append drow
    
    ($ 'body').append cauto
