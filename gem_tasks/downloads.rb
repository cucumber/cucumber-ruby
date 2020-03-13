# frozen_string_literal: true

require 'httparty'
require 'json'

IO.read(File.dirname(__FILE__) + '/versions.txt').each_line do |version|
  json = HTTParty.get("http://rubygems.org/api/v1/downloads/cucumber-#{version.strip}.json")
  puts JSON.parse(json.body)['version_downloads']
end
