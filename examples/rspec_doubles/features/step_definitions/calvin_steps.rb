# frozen_string_literal: true

class CardboardBox
  def initialize(transmogrifier)
    @transmogrifier = transmogrifier
  end

  def poke
    @transmogrifier.transmogrify
  end
end

Given(/^I have a cardboard box$/) do
  transmogrifier = double('transmogrifier')
  expect(transmogrifier).to receive(:transmogrify)
  @box = CardboardBox.new(transmogrifier)
end

When(/^I poke it all is good$/) do
  @box.poke
end
