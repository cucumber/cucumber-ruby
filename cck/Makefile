CCK_FEATURES=$(wildcard ../../../cucumber/compatibility-kit/javascript/features/**/*.feature)
FEATURES=$(patsubst ../../../cucumber/compatibility-kit/javascript/%,%,$(CCK_FEATURES))
NDJSON=$(patsubst %.feature,%.ndjson,$(FEATURES))
SPEC=$(patsubst %.feature,%_spec.rb,$(FEATURES))

default: tested

tested: $(SPEC)
	bundle exec rspec features/**/*_spec.rb

%_spec.rb: %.ndjson templates/specs.rb
	cp templates/specs.rb $@

%.ndjson: %.feature Gemfile.lock %_steps.rb
	-bundle exec cucumber $< --require $(patsubst %.feature,%_steps.rb,$@) --format=message > $@

Gemfile.lock: Gemfile
	bundle install

%.feature:
	mkdir -p $$(dirname $@)
	cp $(patsubst %,../../../cucumber/compatibility-kit/javascript/%,$@) $@

clean:
	-rm Gemfile.lock **/*.feature **/*.ndjson **/*_spec.rb