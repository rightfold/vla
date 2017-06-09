STP_SOURCES=$(shell find src -name '*.stp')
STP_TARGETS=$(patsubst src/%.stp,src/%.stp.purs,${STP_SOURCES})

PSFMDDL_SOURCES=$(shell find src -name '*.psfmddl')
PSFMDDL_TARGETS=$(patsubst src/%.psfmddl,src/%.psfmddl.purs,${PSFMDDL_SOURCES})

HTML_SOURCES=$(shell find src -name '*.html')
HTML_TARGETS=$(patsubst src/%.html,target/%.html,${HTML_SOURCES})

all: target/amalgamation.js ${HTML_TARGETS}

.PHONY: test
test: prereq
	pulp test

prereq: ${STP_TARGETS} ${PSFMDDL_TARGETS}

.PHONY: target/amalgamation.js
target/amalgamation.js: prereq
	mkdir -p $(dir $@)
	pulp browserify -m Main.Client -t $@

src/%.stp.purs: src/%.stp
	sqltopurs --out=$@ $<

src/%.psfmddl.purs: src/%.psfmddl
	psfmddlc --out=$@ $<

target/%.html: src/%.html Template
	mkdir -p $(dir $@)
	./Template $< $@
