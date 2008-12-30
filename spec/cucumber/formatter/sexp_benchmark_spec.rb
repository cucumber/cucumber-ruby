require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'
require 'cucumber/ast'
require 'cucumber/step_mom'
require 'cucumber/formatter/pretty'
require 'cucumber/formatter/feature_factory'
require 'parse_tree'
require 'ruby2ruby'
require 'benchmark'

module Cucumber
  module Formatter
    describe 'SexpTransform' do
      it "should print benchmark for sexp based construction" do
        # Lifted from Ruby2Ruby's #translate method.
        # Cucumber will not use this method (or ParseTree at all),
        # But we need it here to create the sexp (which we will do too)
        sexp = ParseTree.translate(FeatureFactory, :create_feature)
        unifier = Unifier.new
        unifier.processors.each do |p|
          p.unsupported.delete :cfunc # HACK
        end
        sexp = unifier.process(sexp)
        sexps = (1..1000).map{sexp.deep_clone}

        Benchmark.bm do |x|
          x.report "Sexp" do
            sexps.each do |sexp|
              # This is approximately what we'll do in Cucumber
              eval Ruby2Ruby.new.process(sexp.deep_clone)
              create_feature(Object.new)
            end
          end
          x.report "Regular" do
            include FeatureFactory
            sexps.each do |sexp|
              create_feature(Object.new)
            end
          end
        end

      end
    end
  end
end