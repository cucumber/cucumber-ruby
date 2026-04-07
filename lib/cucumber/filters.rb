# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/filters/*.rb"].map(&method(:require))
