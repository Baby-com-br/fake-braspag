require "bundler/setup"

Bundler.require 

module FakeBraspag
  class App < Sinatra::Base
    get '/' do
    end
  end
end
