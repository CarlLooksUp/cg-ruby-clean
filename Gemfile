source 'https://rubygems.org'

ruby '2.1.0'
gem 'rails', '~>4.1.0' #'3.2.13'
gem 'bootstrap-sass' #, '~> 2.3.2.1'
gem 'bcrypt-ruby'  #, '~> 3.0.0'
gem 'simple_form', :git => 'https://github.com/plataformatec/simple_form.git', :tag => 'v3.0.2'
gem 'will_paginate-bootstrap'
gem 'whenever', :require => false

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#Blog gems
gem 'blogit', :git => 'https://github.com/KatanaCode/blogit.git', :branch => 'rails4'
gem 'acts-as-taggable-on'
gem 'bootsy'

#Taxonomy system (for product types)
gem 'ancestry'

#Autocomplete support
gem 'rails4-autocomplete', :git => 'https://github.com/rationalcarl/rails4-autocomplete'

gem 'pg'

gem 'rack-mini-profiler'
gem 'rack-rewrite'

#Stripe payment platform
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

#Roadie for email templates
gem 'roadie'
gem 'roadie-rails'
gem 'htmlentities', '~> 4.3.2'

# Gems used only for assets and not required
# in production environments by default.
group :production do
  gem 'rails_12factor'
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

group :development do
  gem 'annotate'
end

group :development, :test do
    gem 'rspec-rails'
    gem 'guard-rspec'
    gem 'guard-spork'
    gem 'childprocess'
    gem 'spork'
end

group :test do
    gem 'capybara'
    gem 'selenium-webdriver'
    gem 'rb-inotify'
    gem 'libnotify'
end

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
