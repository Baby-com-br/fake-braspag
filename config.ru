$:.unshift File.dirname(File.expand_path(__FILE__)) + '/lib'

require 'fake_braspag'

FakeBraspag.setup(ENV)

run FakeBraspag.app
