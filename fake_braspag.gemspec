Gem::Specification.new do |s|
  s.name        = "fake_braspag"
  s.version     = "1.1.0"
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Fake webservice for the Braspag payment gateway"
  s.email       = "dev@dinda.com.br"
  s.homepage    = "https://github.com/Baby-com-br/fake-braspag"
  s.description = "Fake webservice for the Braspag payment gateway."
  s.authors     = ['Eden Brasil']
  s.license     = "Apache 2"

  s.files         = Dir["README.md", "lib/**/*"]
  s.test_files    = Dir["spec/**/*.rb"]
  s.require_paths = ["lib"]

  s.add_dependency('sinatra', '~> 1.4.5')
  s.add_dependency('builder', '~> 3.2')
  s.add_dependency('tilt-jbuilder', '~> 0.6.0')
  s.add_dependency('redis', '~> 3.1')
  s.add_dependency('activesupport', '~> 4.1')
end
