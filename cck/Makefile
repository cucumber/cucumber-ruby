CCK_FEATURES=$(wildcard ../../../cucumber/compatibility-kit/javascript/features/**/*.feature)
FEATURES=$(patsubst ../../../cucumber/compatibility-kit/javascript/%,%,$(CCK_FEATURES))
NDJSON=$(patsubst %.feature,%.ndjson,$(FEATURES))

default: $(NDJSON)

%.ndjson: %.feature Gemfile.lock step_definitions/cck_step_definitions.rb
	bundle exec cucumber $< --format=message > $@

Gemfile.lock: Gemfile
	bundle install

%.feature:
	mkdir -p $$(dirname $@)
	cp $(patsubst %,../../../cucumber/compatibility-kit/javascript/%,$@) $@

clean:
	rm Gemfile.lock **/*.feature **/*.ndjson