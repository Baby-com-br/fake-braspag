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
  gem "rspec"
  gem 'rack-test', :require => "rack/test"
end

group :test do
  gem "fakeredis", :require => "fakeredis/rspec"
end
