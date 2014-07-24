source 'http://rubygems.org'

ruby '2.1.2'

gem "rake"
gem "nokogiri"
gem "rack", "1.2.3"
gem "sinatra"
gem "unicorn"
gem "rbraspag"
gem "settingslogic", "2.0.6"
gem "cs-httpi", "0.9.5.2"
gem "yajl-ruby"
gem "redis"


group :test, :development do
  gem "pry"
  gem "pry-doc"
  gem "rspec" 
  gem 'rack-test', :require => "rack/test"
  gem "guard-rspec"
end

group :test do
  gem "fakeredis", :require => "fakeredis/rspec"
  if RUBY_PLATFORM =~ /darwin/i
    gem "growl"
    gem 'rb-fsevent', :require => false
  elsif RUBY_PLATFORM =~ /linux/i
    gem "libnotify"
    gem "rb-inotify"
  end
end
