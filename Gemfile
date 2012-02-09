source 'http://rubygems.org'

gem "rake"
gem "nokogiri"
gem "rack", "1.2.3"
gem "sinatra"
gem "unicorn"
gem "rbraspag"
gem "settingslogic", "2.0.6"
gem "cs-httpi", "0.9.5.2"


group :test, :development do
  gem "pry"
  gem "pry-doc"
  gem "rspec" 
  gem 'rack-test', :require => "rack/test"
  gem "guard-rspec"
end

group :test do
  if RUBY_PLATFORM =~ /darwin/i
    gem "growl"
    gem 'rb-fsevent', :require => false
  elsif RUBY_PLATFORM =~ /linux/i
    gem "libnotify"
    gem "rb-inotify"
  end
end
