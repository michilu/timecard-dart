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

pubserve: submodule/dart_timecard_dev_api_client resource
	pub serve --port 8081 --no-dart2js --force-poll

submodule/dart_timecard_dev_api_client:
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

release: submodule/dart_timecard_dev_api_client resource
	pub build

build: submodule/dart_timecard_dev_api_client resource
	pub build --mode=debug

buildserve: build
	cd build/web; python -m SimpleHTTPServer 8081

.PHONY: all clean test resource build $(VERSION_HTML)
