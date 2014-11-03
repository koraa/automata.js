export PATH := $(PWD)/node_modules/.bin:$(PATH)

.PHONY: build clean

build: automata-standalone.js automata.js

automata-standalone.js: automata.js
	browserify -e automata.js -s -o automata-standalone.js

%.js: %.coffee
	coffee -bpc $< > $@

clean:
	rm automata-standalone.js automata.js
