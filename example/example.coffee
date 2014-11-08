## UTILS #########################

window.rand = (a, b=0) ->
  if a > b
    rand b, a
  else
    Math.round a + Math.random() * (b-a)

window.tac = (v) -> v.reverse()

window.sleep  = (a...) -> setTimeout (tac a)...

## GLOBALS #######################

display = null
automat = null
renderer = null
fps = 30

rule = (s, cel) ->
  cel.down().state

initial = (s, cel) ->
  rand 6

## CONTROL #######################

center_display = ->
  ww = window.innerWidth
  wh = window.innerHeight
  s = Math.min(ww, wh) - 50

  display.css
    position: 'absolute'
    width: s
    height: s
    top:  (wh - s)/2
    left: (ww - s)/2


frame_loop = ->
  automat.apply rule
  renderer.render automat

  if fps > 0
    sleep (1000/fps), frame_loop

($ window).resize center_display

($ document).ready ->
  display = $ ".display"
  center_display()

  automat = new Automata.Automat 50, 50
  automat.apply initial

  renderer = new Automata.CanvasRenderer display[0]
  frame_loop()
