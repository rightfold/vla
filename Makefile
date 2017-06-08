PSFMDDL_SOURCES=$(shell find src -name '*.psfmddl')
PSFMDDL_TARGETS=$(patsubst src/%.psfmddl,src/%.psfmddl.purs,${PSFMDDL_SOURCES})

HTML_SOURCES=$(shell find src -name '*.html')
HTML_TARGETS=$(patsubst src/%.html,target/%.html,${HTML_SOURCES})

all: target/amalgamation.js ${HTML_TARGETS}

.PHONY: test
test:
	pulp test

.PHONY: target/amalgamation.js
target/amalgamation.js: ${PSFMDDL_TARGETS}
	mkdir -p $(dir $@)
	pulp browserify -m Main.Client -t $@

src/%.psfmddl.purs: src/%.psfmddl
	psfmddlc --out=$@ $<

target/%.html: src/%.html Template
	mkdir -p $(dir $@)
	./Template $< $@
