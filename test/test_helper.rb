require 'test/unit'
require 'yaml'
require File.dirname(__FILE__) + '/../lib/google/base'

config = YAML::load(open(File.join(ENV['HOME'], '.statwhore')))
Google::Base.establish_connection(config[:username], config[:password])