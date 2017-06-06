all: output/amalgamation.js output/index.html

.PHONY: output/amalgamation.js
output/amalgamation.js:
	mkdir -p $(dir $@)
	pulp browserify -t $@

output/index.html: src/VLA/CRM/Account/Detail.html
	mkdir -p $(dir $@)
	cp $< $@
	echo '<script src="/amalgamation.js"></script>' >> $@
