RES = ./media
HTML = ./site
CSS  = ./style
JS = ./src

TMP  = ./tmp
TARG = ./build

JUICETARG = cupdev

PAT_EXCLUDE = '_proto'

PAT_STYLUS = '.*\.styl'
PAT_COFFEE = '.*\.coffee'
PAT_JS     = '.*\.js'
PAT_CSS    = '.*\.css'
PAT_JADE   = '.*\.jade'
PAT_HTML   = '.*\.html'
PAT_PHP    = '.*\.php'

STYLUSPATH = -I lib -I ./lib/nib/lib/ 

##############################################
# Util Functions

#
# Builds command lines with the files paths matching the expression in the basedir
#
# Params:
#     xargs
# Args:
#     1. Base Dir
#     2. File Match Pattern
#     3. Command...
#
XALL = find $(1) -regex $(2) -print0 | grep -Zvi $(PAT_EXCLUDE) -zZ | sort -z | xargs -t -0

#
# Compile coffescript sources
## Params:
#     coffee
# Args:
#     1. Output dir
#     2. Files...
#
COFFEE_RELEASE = coffee -bc -o
COFFEE_DEBUG   = coffee -bc -l -o
ifdef DEBUG
    COFFEE = $(COFFEE_DEBUG)
else
    COFFEE = $(COFFEE_RELEASE)
endif

#
# Squash JS sources
# 
# Params:
#     juicer
# Args:
#     1. Output dir
#     2. Files...
#
_JUICER_BASE    = juicer -v merge -c none -f
_JUICER_YUM     = 
JUICER_RELEASE = $(_JUICER_BASE) $(_JUICER_YUM) -s -o 
JUICER_DEBUG   = $(_JUICER_BASE) -s -m none -o  
ifdef DEBUG
    NOYUM=1
endif
ifdef EXP_CLOSURE
    NOYUM=1
endif
ifdef NOYUM
    JUICER = $(JUICER_DEBUG)
else
    JUICER = $(JUICER_RELEASE)
endif

#
# Pipe through closure compiler.
# Can produce highly optimized code,
# but is a little dangerous.
#
# Params:
#     Google Closure Compiler
# Args:
#     1. Output file
#     2. Files...
#
_CLOSURE_LOC = lib/closure/compiler.jar 
_CLOSURE_O = --compilation_level ADVANCED_OPTIMIZATIONS
CLOSURE_RELEASE = 2>/dev/null java -jar $(_CLOSURE_LOC) $(_CLOSURE_O)  --js_output_file 
CLOSURE_DEBUG = sh -c 'cp "$$1" "$$0"'
ifdef EXP_CLOSURE
    CLOSURE = $(CLOSURE_RELEASE)
else
    CLOSURE = $(CLOSURE_DEBUG)
endif

#
# Compiles the given stylus sources to css
#
# Params:
#     stylus
# Args:
#     1. Output dir
#     2. Files...
#
STYLUS_RELEASE = stylus --include-css -c -o
STYLUS_DEBUG   = stylus --include-css -f -l -o
ifdef DEBUG
    STYLUS = $(STYLUS_DEBUG)
else
    STYLUS = $(STYLUS_RELEASE)
endif

#
# Compiles the given jade sources to html
#
# Params:
#     jade
# Args:
#     1. Output dir
#     2. Files...
#
JADE_RELEASE = jade -D -O
JADE_DEBUG   = jade -P -O
ifdef DEBUG
    JADE = $(JADE_DEBUG)
else
    JADE = $(JADE_RELEASE)
endif

##############################################
# Targes

all: deps mktarg resources closure css_juice jade php plainhtml

resources:
	rsync -ravH --exclude=$(PAT_EXCLUDE) "$(RES)"/* "$(TARG)" || echo "No resources to copy"

coffee:
	$(call XALL,"$(JS)",$(PAT_COFFEE)) $(COFFEE) "$(TMP)"

plainjs:
	rsync -ravH --exclude=$(PAT_EXCLUDE) "$(JS)"/*.js "$(TMP)" || echo "No resources to copy"

juice: plainjs coffee
	$(call XALL,"$(TMP)",$(PAT_JS)) $(JUICER) "$(TMP)/$(JUICETARG).js"

closure: juice
	$(CLOSURE) "$(TARG)/$(JUICETARG).js" "$(TMP)/$(JUICETARG).js"

stylus:
	$(call XALL,"$(CSS)",$(PAT_STYLUS)) $(STYLUS) "$(TMP)" $(STYLUSPATH) 

plaincss:
	rsync -ravH --exclude=$(PAT_EXCLUDE) "$(CSS)"/*.css "$(TMP)" || echo "No resources to copy"

css_juice: stylus plaincss
	$(call XALL,"$(TMP)",$(PAT_CSS)) $(JUICER) "$(TMP)/$(JUICETARG).css"
	cp "$(TMP)/$(JUICETARG).css" "$(TARG)/$(JUICETARG).css"

jade:
	$(call XALL,"$(HTML)",$(PAT_JADE)) $(JADE) "$(TARG)" # "$(HTML)"

plainhtml:
	rsync -ravH --exclude="." --include=$(PAT_HTML) --exclude=$(PAT_EXCLUDE)  "$(HTML)"/* "$(TARG)" || echo "No resources to copy"

php:
	rsync -ravH --exclude="." --include=$(PAT_PHP) --exclude=$(PAT_EXCLUDE) "$(HTML)"/* "$(TARG)" || echo "No resources to copy"

mktarg:
	mkdir -p "$(TARG)"
	mkdir -p "$(TMP)"

clean: clean-deps
	rm -Rfv "$(TARG)" "$(TMP)"

###############################################
# Deps

deps: 
	# jquery 
	# pinktext jquery-url

jquery:
	make -C lib/jquery
	cp lib/jquery/build/release.js lib/jquery.js

pinktext:
	$(COFFEE) lib lib/pinktext/browser.coffee
	mv lib/browser.js lib/pinktext.js

jquery-url:
	cp lib/jquery-url/jquery.url.js lib/jquery-url.js

clean-deps:
	# make -C lib/jquery clean
	# rm lib/*.js
