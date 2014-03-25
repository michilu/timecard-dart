VERSION_HTML=$(TEMPLATE_DIR_PATH)/version.html
VERSION=$(shell git describe --always --dirty=+)
RESOURCE_DIR_PATH=web lib
RESOURCE_DIR = $(foreach dir,$(shell find $(RESOURCE_DIR_PATH) -type d),$(dir))

all: pubserve


.SUFFIXES: .haml .html
.haml.html:
	haml -f html5 -t ugly $< $@
HAML = $(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.haml))
HTML = $(HAML:.haml=.html)

.SUFFIXES: .sass .css
.sass.css:
	compass compile $< -c $(CSS_DIR)/config.rb
.SUFFIXES: .sass .min.css
.sass.min.css:
	compass compile --environment production $< -c $(CSS_DIR)/config.rb
	mv $*.css $@
SASS = $(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.sass))
CSS = $(SASS:.sass=.css)
MINCSS = $(SASS:.sass=.min.css)

resource: $(HTML) $(CSS) $(MINCSS)

pubserve: submodule/timecard_dev_api resource
	pub serve --port 8081 --no-dart2js --force-poll
	@#pub serve --port 8081 --minify --force-poll

submodule/timecard_dev_api:
	cd submodule/discovery_api_dart_client_generator; pub install
	submodule/discovery_api_dart_client_generator/bin/generate.dart --no-prefix -i timecard-dev.discovery -o submodule

clean:
	find . -type d -name .sass-cache |xargs rm -rf
	find . -name "*.sw?" -delete
	find . -name .DS_Store -delete
	rm -f $(CSS)
	rm -f $(HTML)
	rm -f $(MINCSS)

$(VERSION_HTML):
	@if [ "$(VERSION)" != "$(strip $(shell [ -f $@ ] && cat $@))" ] ; then\
		echo 'echo $(VERSION) > $@' ;\
		echo $(VERSION) > $@ ;\
	fi;

.PHONY: all clean test resource $(VERSION_HTML)
