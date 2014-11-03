export PATH := $(PWD)/node_modules/.bin:$(PATH)

.PHONY: all lib example clean

all: lib example

F_EXAMPLE = example/index.html example/example.css example/example.js
example: lib $(F_EXAMPLE)

F_LIB = automata-standalone.js automata.js
lib: $(F_LIB)

automata-standalone.js: automata.js
	browserify -e automata.js -s Automata -o automata-standalone.js

%.js: %.coffee
	coffee -bpc $< > $@

%.css: %.styl
	stylus $<

%.html: %.jade
	jade -P -p app/ < $< > $@

clean:
	rm -f $(F_LIB) $(F_EXAMPLE)
