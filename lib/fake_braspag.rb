require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.setup

require 'sinatra/base'

$: << File.dirname(__FILE__)

module FakeBraspag
  class Application < Sinatra::Base
  end
end
