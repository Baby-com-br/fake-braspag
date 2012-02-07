require 'rspec'
require 'rack/test'

ENV ||= {}
ENV["SINATRA_ENV"] = "test"

$:.unshift File.dirname(File.expand_path(__FILE__)) + "/lib"
require "fake_braspag"
Dir[File.dirname(__FILE__) + "/support/*.rb"].each { |f| require f }

def app
  FakeBraspag::App
end

RSpec.configure do |config|
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.include Rack::Test::Methods
end
