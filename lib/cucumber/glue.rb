# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/glue/*.rb"].map(&method(:require))
