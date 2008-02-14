Google Base Class is a base for authenticating to google and making requests to google services.

=Installation

sudo gem install googlebase

=Usage

===Establish A Connection

The code below shows how to use the gem by itself. It checks if username and password are correct (raising Google::LoginError on FAIL) and stores the session id internally. Then you can make requests and the session id is automatically passed in a cookie.

	require 'google/base'
	Google::Base.establish_connection('username', 'password')
	Google::Base.get('http://google.com/reader/path/to/whatever/')
	Google::Base.get('https://google.com:443/analytics/home/') # to make an ssl request

===Inheritance

This example takes things a bit farther and shows how to use this class simply as a base to get some methods for free and then wrap whatever google service you would like.
	
	require 'google/base'
	Google::Base.establish_connection('username', 'password')
	module Google
	  module Reader
	    class Base < Google::Base
	      class << self
	        def get_token
	          get("http://www.google.com/reader/api/0/token")
	        end
	      end
	    end
	  end
	end

	puts Google::Reader::Base.get_token