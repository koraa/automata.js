($ document).ready ->
  window.auto = new Automata.Automat 40, 40,
    init: (i,x,y) -> Math.round(x/3) % 4
    rule: (i,x,y,s,n) -> s.right 3
    click: (i) -> (i+1)%10
  
  auto.start(500)

