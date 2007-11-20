# Base class that does all the work and can be inherited from for goodies.
require 'uri'
require 'net/https'
require 'net/http'

module Google
  # Exception raised upon login problem. Most likely incorrect username or 
  # password but could mean problem with google service.
  class LoginError < Exception; end
  URL        = 'http://www.google.com'
  LOGIN_URL  = 'https://www.google.com:443/accounts/ClientLogin'
  SOURCE     = 'GReader Ruby API'
  
  class Base
    class << self
      # Given an email and password it creates a new connection 
      # which will be used for this class and all sub classes
      def establish_connection(email, password)
        @@connection = new(email, password)
      end
      
      # Returns the current connection
      def connection
        @@connection
      end
      
      # Changes the current connection to the one provided
      def connection=(new_connection)
        @@connection = new_connection
      end
      
      # Makes a get request to a google service using 
      # the session id from the connection's session
      def get(url)
        request 'get', url
      end
      
      private
        # This will eventually implement get and post 
        # but I haven't needed post yet
        def request(method, url)
          url    = URI.parse(url)
          req    = Net::HTTP::Get.new(url.request_uri, @@connection.headers)
          http   = Net::HTTP.new(url.host, url.port)
          result = http.start() { |conn| conn.request(req) }
    			result.body
        end
    end
    
    # Session id returned from google login request
    attr_accessor :sid
    
    # Creates a new instance of the connection class using 
    # the given email and password and attempts to login
    def initialize(email, password)
      @email, @password = email, password
      login
    end
    
    # Makes authentication request to google and sets the sid
    # to be passed in a cookie with each authenticated request.
    #
    # Raises Google::LoginError if login is unsuccessful
    def login
      url = URI.parse(LOGIN_URL)
      req = Net::HTTP::Post.new(url.request_uri)
      req.set_form_data({
        'Email'    => @email, 
        'Passwd'   => @password, 
        'source'   => SOURCE, 
        'continue' => URL,
      })
      http         = Net::HTTP.new(url.host, url.port)
			http.use_ssl = true
			result       = http.start() { |conn| conn.request(req) }
			@sid         = extract_sid(result.body)
			raise LoginError, "Most likely your username and password are wrong." unless logged_in?
    end
    
    # Returns true or false based on whether or not the session id is set
    def logged_in?
      @sid ? true : false
    end
    
    # Outputs the headers that are needed to make an authenticated request
    def headers
      {'Cookie' => "Name=#{@sid};SID=#{@sid};Domain=.google.com;Path=/;Expires=160000000000"}
    end
    
    private
      def extract_sid(body)
        matches = body.match(/SID=(.*)/)
        matches.nil? ? nil : matches[0].gsub('SID=', '')
      end
  end
end