require "bundler/setup"

ENV["RACK_ENV"] ||= "development"

Bundler.setup

require 'sinatra'

$: << File.dirname(__FILE__)

module FakeBraspag
  class App < Sinatra::Base
    configure do
      set :root, File.dirname(__FILE__)
    end
  end
end
