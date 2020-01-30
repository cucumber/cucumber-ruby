MONOREPO_PATH ?= ../../../cucumber
CCK_FEATURES=$(wildcard $(MONOREPO_PATH)/compatibility-kit/javascript/features/**/*.feature)
FEATURES=$(patsubst $(MONOREPO_PATH)/compatibility-kit/javascript/%,%,$(CCK_FEATURES))
NDJSON=$(patsubst %.feature,%.ndjson,$(FEATURES))
SPEC=$(patsubst %.feature,%_spec.rb,$(FEATURES))

default: tested

tested: $(SPEC)
	bundle exec rspec features/**/*_spec.rb

%_spec.rb: %.ndjson templates/specs.rb
	cp templates/specs.rb $@

%.ndjson: %.feature %_steps.rb Gemfile.lock
	-bundle exec cucumber $< --require $(patsubst %.ndjson,%_steps.rb,$@) --format=message > $@

Gemfile.lock: Gemfile
	bundle install

%.feature:
	mkdir -p $$(dirname $@)
	cp $(patsubst %,$(MONOREPO_PATH)/compatibility-kit/javascript/%,$@) $@

clean:
	-rm Gemfile.lock **/*.feature **/*.ndjson **/*_spec.rb
