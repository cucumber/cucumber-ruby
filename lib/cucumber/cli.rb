# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/cli/*.rb"].map(&method(:require))
