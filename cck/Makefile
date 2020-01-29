CCK_FEATURES=$(wildcard ../../../cucumber/compatibility-kit/javascript/features/**/*.feature)
FEATURES=$(patsubst ../../../cucumber/compatibility-kit/javascript/%,%,$(CCK_FEATURES))
NDJSON=$(patsubst %.feature,%.ndjson,$(FEATURES))
TESTED=$(patsubst %.feature,%.tested,$(FEATURES))

default: $(NDJSON)

tested: $(TESTED)

%.tested: %.ndjson
	diff --unified $< $(patsubst %.ndjson,../../../cucumber/compatibility-kit/javascript/%.ndjson,$<)

%.ndjson: %.feature Gemfile.lock %_steps.rb
	-bundle exec cucumber $< --format=message > $@

Gemfile.lock: Gemfile
	bundle install

%.feature:
	mkdir -p $$(dirname $@)
	cp $(patsubst %,../../../cucumber/compatibility-kit/javascript/%,$@) $@

clean:
	rm Gemfile.lock **/*.feature **/*.ndjson