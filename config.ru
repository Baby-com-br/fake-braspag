$:.unshift File.dirname(File.expand_path(__FILE__)) + "/lib"
require 'fake_braspag'
use ::Rack::ShowExceptions
run FakeBraspag::App
