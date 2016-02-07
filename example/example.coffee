{random, round} = Math

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
fps = 1

## CONTROL #######################

rules =
  "Game Of Life": (state, cell) ->
    r = [-1..1]
    live = _.sum(_.map (cartesian r, r), ([x,y]) -> cell.get(x,y).state) - state
    switch live
      when 2 then state # survival
      when 3 then 1     # survival, reproduction
      else        0     # overcrowded, underpopulation
  "Clear Random Binary": -> round random()

center_display = ->
  ww = window.innerWidth
  wh = window.innerHeight
  s = Math.min(ww, wh) - 10

  display.attr
    width: s
    height: s
  display.css
    position: 'absolute'
    top:  (wh - s)/2
    left: (ww - s)/2

frame_loop = ->
  automat.update rules["Game Of Life"]
  renderer.render automat

  if fps > 0
    sleep (1000/fps), frame_loop

($ window).resize center_display

($ document).ready ->
  display = $ ".display"
  center_display()

  automat = new Automata.Automat 100, 100
  automat.update rules["Clear Random Binary"]

  renderer = new Automata.CanvasRenderer display[0]
  frame_loop()
