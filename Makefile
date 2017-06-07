HTML_SOURCES=$(shell find src -name '*.html')
HTML_TARGETS=$(patsubst src/%.html,target/%.html,${HTML_SOURCES})

all: target/amalgamation.js ${HTML_TARGETS}

.PHONY: test
test:
	pulp test

.PHONY: target/amalgamation.js
target/amalgamation.js:
	mkdir -p $(dir $@)
	pulp browserify -m Main.Client -t $@

target/%.html: src/%.html Template
	mkdir -p $(dir $@)
	./Template $< $@
