##############################
# BOOTSTRAP

###
@depend ../lib/jquery.js
###

##############################
# Util

###
Cast var to array:

Arg:
    o - The var to cAST
Return:
    (array) Either o or [o].
###
arr = (o) ->
    return o if o instanceof Array
    [o]

###
Manage empty lists:

Args:
    d=[] - Default value
    x    - Concrete value
Return:
    d if x is not defined
    x otherwise
Aliases:
    - sanempty
    - def
###
sanempty = (a...) ->
    if a.length > 1
        [d, x] = a
    else
        [x] = a
        d = []
    return d unless x?
    return x
def = sanempty

###
Log command with a return value.

Args:
    a... - The values to print
Return:
    The last element of a
###
flog = (a...) ->
    console.log a...
    last a

#
# Obtain the real position in px of an element
#
find_pos = (o) ->
    return [0,0] if !o
    
    p = find_pos o.parent()
    [o.offsetLeft + p[0], o.offsetTop + p[1]]

#
# Remove duplicates from a list 
#
uniq = (l) ->
    d = {}
    d[e] = e for e in l
    e for _,e of d

#
# Map/Sort 
#
msort  = (l, f, s_f = (a,b) -> a > b) ->
    mL = [i, f e] for e,i in l
    sL = mL.sort (a,b) ->
        s_f a[1], b[1]
    
    o = []
    for [i, e] in sL
        o[i] = e
    return o

#
# Y-Combinator cheating
# Wraps the input function,
# so that the first argument
# is always itself.
#
Y = (F) ->
    F_ = (a...) ->
        F(F_, a...)

#
# Reverse do,
# calls the last arguments with all args before.
#
od = (a..., F) ->
    F a...

#
# Different functionals
#
reduce = (a...) ->
    if a.length == 3
        [l_, i_, f_] = a
    else if a.length == 2
        # Definition for empty list input
        return [] if a[0].length < 
            1
        l_ = tail a[0]
        i_ = head a[0]
        f_ = a[1]
    else
        throw "The reduce function requires 2 or 3 args"

    # This is the actual function def,
    # the rest is just arg
    # and special case handles
    # l - The list
    # R - The last result/initial value
    # f - The function
    # OL - The original list
    # ind - The index
    do Y (ME, l=l_, R=i_, f=f_, ind=0) ->
        return R if ind >= l.length
        ME l,
           (f i, (head l), l, ind),  # Function call
           f, ind+1

#
# Select the smallest element
#
min = (l) ->
    reduce l, Math.min
        
#
# Sum the elements
#
sum = (l) ->
    reduce l, 0, (a, b) ->
        a+b

#
# Apply the function to each list element
#
map = (l, f) ->
    for e,i in l
        f e, l, i


###
Relates each n elements of a list to each other.
Relation is _not_greedy_.
Only existing elements will be related
(the relation terminates at element (len l)-n.

Special cases:
    n=0 => Infinite Loop
    n=1 <=> map
    n>1 := Real relation
Args:
    (1) l - The list to relate the elements of
    (3) n - The number of Elements to relate
    (2) f - The Relation function
        Args:
            es... - The elements beingrelated
Return:
    The result of each relation
###
__relate = (l, n, f) ->
    for i in [0..((len l)-1)]
        f [i...i+n]
relate = (a...) ->
    if (len a) > 2
        [l, n, f] = a
    else
        n = 2
        [l, f] = a
    __relate l, n, f

###
Check if all elements given are equal

Args:
    l - The list of elements to check
Return:
    If all given elements are equal
###
eq = (l) ->
    all relate l, (a,b) ->
        a == b

# True if all cntaining elements are true
#
all = (l, f=(x) -> x) ->#
    return true if l.length < 1
    reduce (map l, f), (a, b) ->
        a && b

#
# True if any of the lists elements is ture
#
any = (l, f=(x) -> x) ->
    return true if l.length < 1
    reduce (map l, f), (a, b) ->
        a || b

#
# Remove the elements that dont match the filter
#
filter = (l, f, r=[]) ->
    for e,i in l
        r.push e if f e, l, i
    r

#
# Length of list (for convenicence; Proxy to builtin)
#
len = (l) ->
    l.length

#
# Cyclic module:
#
#    -1 `amod x -> x-1
#    +1 `amod x -> +1 ; x>=1
#
cyclmod = (i,d) ->  ((i%d)+d)%d

#
# Cyclic at,
# always gives a valid element
# See: cyclmod()
#
cyclat = (l, i, cycl=true) ->
    i = cyclmod i, (len l) if cycl
    l[i]

###
Call the given function n times, while passing the index.

Args:
    (int) x - The amount of calls to dy
    (fun) f - The Function to call
Returns:
    The result of each call
###
iter = (x, F) ->
    for i in [0..x]
        F i

###
Rotate a 2D list by 90deg//Swap rows with colums

Args:
    aL - The 2D list
###
zip = (aL) ->
    iter (max map al, len), (i) ->
        map aL, (L) ->
            L[i]

###
Combine multiple lists by calling the gven
function with all elements n of all lists.

Args:
    1. List 1
    2. List 2
    ...
    n. The Function
Returns:
    The combination...
###
combine = (aL..., F) ->
    map (zip aL), (a) ->
        F a...
#
# Avrage an array of ints
#
avrage = (l) ->
    (sum l) / (len l)

#
# Join a list to a single string
#
join = (a...) ->
    if a.length > 1
        l = rtail a
        s = last a
    else
        l = head a
        s = " "
    
    #flatten(l).map(String).join s
    reduce (flatten l), (a,b) ->
        a + s + String b

#
# Flatten a list
#
flatten = (l) ->
    return l unless l instanceof Array
    a = l.map (x) -> flatten x
    reduce a, [], (a, b) -> a.concat b

#
# List access
#
head  = (l, i=0) -> l[i]
last  = (l, i=0) -> l[l.length-1 -i]
tail  = (l, i=1) -> l[(i)..l.length]
rtail = (l, i=1) -> l[0...l.length-i]


#
# Asynchronus wait
# Basically setTimeout, just with reversed args
#
await = (T, f) ->
    setTimeout f, T

#
# Asynchronus repeat
# Basically setInterval, just with reversed args
#
arepeat = (T, f) ->
    setInterval f, T

#
# Easy dict access
#
keys    = (d) ->    k  for k,v of d
values  = (d) ->    v  for k,v of d
kvpairs = (d) -> [k,v] for k, v of d

#
# Extend the first given dictionary with the consecutive ones
#
extend = (D, dis...) ->
    for sd in dis
        for k,v of sd
            D[k] = v
    return D

#
# Like `extend`, but creates a new Dictionary instad of extending the first given one
#
merge = (dis...) ->
    extend D, dis...
#
# Generate a link text from Text and dest.
#
comp_link = (text, dest) ->
    '<a href="' + dest + '">' + text + '</a>'

###
#
# Check if the given string beginns with the given arg.
#
# Args
# ====
#
# 1. s  - String
# 2. pr - Prefix
# 
# Returns
# =======
#
# **true** or **false**
#
###
beginswith = (s, pr) ->
    s[0...(len pr)] == pr

###
# 
# Remove a prefix from a string
#
# Args
# ====
#
# 1. s  - String
# 2. pr - Prefix
#
# Returns
# =======
#
# The string without the prefix or **null**
#
# Alias
# =====
#
# * __extprefix - Unsafe variant, use if you are shure, the string has that prefix
#
###
__extprefix = (s, pr) ->
    s[(len pr)...(len s)]
extprefix = (s, prefix) ->
   if beginswith s, pr
       __extprefix s, pr
  

argv = ->
    return @argv unless @argv?
    
    @argv = {}

    u = window.location.href.split("?")
    return @argv if u.length < 2

    u = u[1].split("#")[0]
    return @argv if u.length < 1

    for kvp in u.split "&"
        [k,v] = kvp.split "="
        continue unless k? && v?
        @argv[k] = v
    @argv

garg = (x, d) ->
    argv()[x] || d

#######################
# Functional

# Runs each dwith the given args
runeach = (l, a...) ->
    f a... for f in l

# Map for assiocative arrays.
dmap_l = (d, f) ->
    f k, d[k] for k of d

#######################
# Text similarity

#
# Computes the Levensthein Distance
#
levdist = (s, t) ->
    n = s.length
    m = t.length
    return m if n is 0
    return n if m is 0

    d       = []
    d[i]    = [] for i in [0..n]
    d[i][0] = i  for i in [0..n]
    d[0][j] = j  for j in [0..m]

    for c1, i in s
        for c2, j in t
            cost = if c1 is c2 then 0 else 1
            d[i+1][j+1] = Math.min d[i][j+1]+1, d[i+1][j]+1, d[i][j] + cost
    
    d[n][m]

#
# Divide strings into words >= 4 chars
#
tokenize = (s) ->
    String(s).toLowerCase().split(/[^\wßäöü]/).filter (w) ->
        w.length > 3

#
# Computes a textdistance by averaging the
# nearest_word (-> nearest_word) distance for 
# every token (-> tokenize) in the text.
#
textdist = (a_, b_) ->
    a = tokenize a_
    b = tokenize b_
    
    # Default to -1 if therer are not enough tokens
    return -1 if a.length == 0 || b.length == 0

    # a is the smaller
    [a,b] = [b,a] if b < a

    # Levcompute
    pd = map a, (w) ->
        (nearest_word w, b)[2]

    # Divide by len a
    (sum pd) / a.length

#
# Counts the number of keywords common to both text,
# where a keyword is a token (-> tokennize) that has
# a levingdistance < 5 to a token in the other string.
# 
# Returns
#   A to component array: 
#       * Number of common keywords
#       * Avrage distance of keywords (NEGATED for easy compairson)
#
keywordnum = (a_, b_) ->
    a = tokenize a_
    b = tokenize b_

    # Default to -1 if therer are not enough tokens
    return -1 if a.length == 0 || b.length == 0

    # a is the smaller
    [a,b] = [b,a] if b < a

    # Levcompute
    L = map a, (w) ->
        (nearest_word w, b)[2]

    # Filter all
    L = filter L, (x) -> x < 5

    # OUT
    [ (len L), -(avrage L)]

#
# Returns the word with the smallest levdist
# RETURN [ a[n], m, levdist(w, a[n]) ]
#
nearest_word = (w, a...) ->
    l = flatten a
    L = for e, i in l # DISTANCE
        [e, i, (levdist w, e)]
    reduce L, (a, b) -> # MIN
        return a if a[2] < b[2]
        b

#
# Returns the text with the smallest topictist
# RETURN [ a[n], m, topicdist(t, a[n]) ]
#
nearest_text = (t, a...) ->
    l = flatten a
    ds = for e,i in l # DISTANCE
        [e, i, (keywordnum t, e)]
    filter ds, (t) -> # IGNORE -1 distance
        t[2] > -1
    reduce ds, (a, b) -># MIN
        return a if a[2] >= b[2]
        b

################################
# Jquery classes extension

jQuery.fn.classes = -> 
    flatten @map ->
        e = $ @
        ((sanempty e.attr 'class').split ' ').filter (x) -> 
            x.length > 0

jQuery.fn.set_classes = (l) ->
    @attr 'class', join l

jQuery.fn.pop_class = (c) ->
    @each ->
        e = $ @
        e.set_classes filter e.classes(), (x) ->
            x != c

jQuery.fn.push_class = (c) ->
    @each ->
        e = $ @
        e.attr 'class', (sanempty e.attr 'class') + " " + c

###############################
# Misc

jQuery.fn.active = ->
    any @map ->
        @ == document.activeElement

###############################
# Approve/Denial

jQuery.fn.approve = ->
    @pop_class 'denial'
    @pop_class 'approve'
    @push_class 'approve'
    @attr 'check_result', '1'
    @trigger "approval-change"

jQuery.fn.denial = ->
    @pop_class 'approve'
    @pop_class 'denial'
    @push_class 'denial'
    @attr 'check_result', '0'
    @trigger "approval-change"

jQuery.fn.ad_reset = ->
    @pop_class 'approve'
    @pop_class 'denial'
    @attr 'check_result', ''
    @trigger "approval-change"

jQuery.fn.isApproved = ->
    vs = @map ->
        sanempty '0', ($ @).attr 'check_result'
    all vs, (x) -> x == '1'
   
jQuery.fn.onApprovedClick = (f) ->
    @click ->
        if ($ @).isApproved()
            do f

###############################
# Selectors

jQuery.fn.findParent = (sel) ->
    pa = $ @parent()
    return pa if pa.is sel
    return null if pa.length < 1
    pa.findParent sel

###############################
# JQuery GEOMETRY extensions

#
# Center the element in the current element
#
jQuery.fn.center = ->
    @css "position","relative"
    @css "top",  (@parent().height() - @height()) / 2 + "px"
    @css "left", (@parent().width()  - @width()) / 2 + "px"

#
# Center the element vertically in the current element
#
jQuery.fn.centerV = ->
    @css "position","relative"
    @css "top",  (@parent().height() - @height()) / 2 + "px"


#
# Force an aspect ratio by setting the height.
#
jQuery.fn.aspectW = (asp) ->
    @css "width", @height()# asp + "px"

#
# Set height = width
#
jQuery.fn.squareW = -> 
    @aspectW 1

#
# Force an aspect ratio by setting the height.
#
jQuery.fn.aspectH = (asp) ->
    @css "height", @width()# asp + "px"

#
# Set width = height
#
jQuery.fn.squareH = ->
    @aspectH 1

#
# Square the object, using min(width, height) as the reference side
#
jQuery.fn.square = ->
    @css "width",  "",
         "height", ""    

    parent = @parent()
    w = parent.width()
    h = parent.height()

    if w == Math.min w, h
        @squareH()
    else
        @squareW()

#
# Fill the entire parent element downwards.
#
jQuery.fn.stretchD = ->
    pos = @position()
    if pos?
        @css "height", @parent().height() - pos.top + "px"
    @

#
# Fill the entire parent element upwards.
#
jQuery.fn.stretchU = ->
    pos = @position()

    if pos?
        @css "height", @parent().height() + pos.top + "px",
             "top", "0px"
    @

#
# Fill the entire parent element rightwards.
#
jQuery.fn.stretchR =-> 
    pos = @position()

    if pos?
        @css "height", @parent().width() - pos.left
    @

#
# Fill the entire parent element leftwards.
#
jQuery.fn.stretchL = ->
    pos = @position()

    if pos?
        @css "height", @parent().width() + pos.left + "px",
             "left", "0px"
    @

###############################
# JQuery CONTENT extensions

#
# Generates the text-only header
#
jQuery.fn.genContentArrayLinks = (s) ->
    ltext = (dmap_l s, (k, v) ->
        comp_link k, v["url"]
    ).join @attr 'divider'
    @html ltext
    @

#
# Generates the text-only header
#
jQuery.fn.genContentJSONLinks = (json_url) -> 
    del = @
    $.getJSON json_url, (o) ->
        del.genContentArrayLinks(o)
    @

###################
# Event management

resizeListeners = []
fireResize = (ev) -> runeach resizeListeners, ev
onResize   = (f)  -> resizeListeners.push f
$(window).bind "resize", fireResize


readyListeners = []
fireReady = (ev) -> runeach readyListeners, ev
onReady =   (f)  ->  readyListeners.push(f)
$(document).ready fireReady


domChangeListeners = []
fireDomChange = (ev) -> runeach domChangeListeners, ev
onDomChange   = (f)  -> domChangeListeners.push f
$(window).bind "DOMSubtreeModified", fireDomChange

#
# Hook helper:
# Runs each don each hook for each JQuery ID.
# Each argument can be a list or a single object.
# 
# Arguments:
#     1. id   - The JQuery ID(s) to apply the d(s) on
#     2. hook - The Hook(s) to run the d(s) for
#     3. f    - The Function(s) to run for every ID on each Hook
#
hook = (id, hookf, f) ->
    # Enshure all elems are arrays
    id    = arr id
    hookf = arr hookf
    f     = arr f

    # Create the execution d
    runeach hookf, (ev) ->
        for ix in id
            runeach f, ($ ix if ix?)

hook ".center",   [onResize, onReady, onDomChange], (e) -> e.center()
hook ".centerV",  [onResize, onReady, onDomChange], (e) -> e.centerV()
hook ".squareH",  [onResize, onReady, onDomChange], (e) -> e.squareH()
hook ".squareW",  [onResize, onReady, onDomChange], (e) -> e.squareW()
hook ".square",   [onResize, onReady, onDomChange], (e) -> e.square()
hook ".stretchL", [onResize, onReady, onDomChange], (e) -> e.stretchL()
hook ".stretchR", [onResize, onReady, onDomChange], (e) -> e.stretchR()
hook ".stretchU", [onResize, onReady, onDomChange], (e) -> e.stretchU()
hook ".stretchD", [onResize, onReady, onDomChange], (e) -> e.stretchD()

hook '[include]', onReady, (e) ->
    e.load e.attr 'include'

hook '[genContent="JSONLinks"]', onReady, (e) ->
    e.genContentJSONLinks e.attr 'linkFile'

hook ['input[regexApprove]', 'textarea[regexApprove]'], onReady, (e) ->
    f = ->
        n = $  @
        if n.val().match (new RegExp (n.attr 'regexApprove'))
            n.approve()
        else
            n.denial()
    e.change f
    e.keyup f

hook ['input[contApprove]', 'textarea[contApprove]'], onReady, (e) ->
    f = ->
        n = $  @
        if n.val().length > 0
            n.approve()
        else
            n.denial()
    e.change f
    e.keyup f


hook ['[dependentApprove]'], onReady, (e) ->
    v = e.attr 'dependentApprove'
    s = "[providesTo=#{v}]"
    f = ->
        if $(s).isApproved()
            e.approve()
        else
            e.denial()
    $(s).bind "approval-change",f


###############################################
# Label correction

hook "[label]", onReady, (e) ->
    e.each ->
        n = $ @
        n.before """
                 <label class="#{sanempty n.attr 'class'} labgen"
                        id="#{sanempty n.attr 'id'}"
                        for="#{sanempty n.attr 'name'}">#{n.attr 'label'}</label>
                 """

hook ".hidelabel", onReady, (e) ->
    e.each ->
        lab = $ @
        
        inp = $ "[name=#{lab.attr "for"}]"
        f =->
            n = $ @

            if  inp.active() || n.val().length > 0
                lab.css "visibility", "hidden"
            else
                lab.css "visibility", "visible"
        
        inp.change f
        inp.keyup f
        inp.focus f
        inp.blur f
        inp.each f
