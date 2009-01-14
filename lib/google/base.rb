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
  SOURCE     = 'Google Auth Base Ruby Gem'
  
  class Base
    # Given an email and password it creates a new connection 
    # which will be used for this class and all sub classes.
    #
    # Raises Google::LoginError if login fails or if, god forbid,
    # google is having issues.
    def self.establish_connection(email, password)
      @@connection = new(email, password)
    end
    
    # Returns the current connection
    def self.connection
      @@connection
    end
    
    # Changes the current connection to the one provided.
    # If in an app you store the connection in a session, 
    # you can reuse it instead of establishing a new connection
    # with each request. 
    #
    # Usage: 
    #   Google::Base.connection = session[:connection] # => or whatever
    def self.connection=(new_connection)
      @@connection = new_connection
    end
    
    # Makes a get request to a google service using 
    # the session id from the connection's session
    # 
    # Usage:
    #   get('http://google.com/some/thing')
    #   get('http://google.com/some/thing', :query_hash => {:q => 'test', :second => 'another'})
    #     # makes request to http://google.com/some/thing?q=test&second=another
    #   get('http://google.com/some/thing?ha=poo', :query_hash => {:q => 'test', :second => 'another'}, :qsi => '&')
    #     # makes request to http://google.com/some/thing?ha=poo&q=test&second=another
    def self.get(url, o={})
      options = {
        :query_hash => nil,
        :qsi => '?'
      }.merge(o)
      request 'get', url, options
    end
    
    # Makes a post request to a google service using
    # the session id from the connection's session
    #
    # Usage:
    #   post('http://google.com/some/thing', :form_data => {:one => '1', :two => '2'})
    #     # makes a post request to http://google.com/some/thing with the post data set to one=1&two=2
    #   post('http://google.com/some/thing', :raw_data => "some=thing&another=thing")
    #     # makes a post request to http://google.com/some/thing with the post data set to some=thing&another=thing
    def self.post(url, o={})
      options = {
        :form_data => nil,
        :raw_data => nil,
      }.merge(o)
      if options[:raw_data]
        url    = URI.parse(URI.escape(url))
        http   = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if url.port == 443
        result = http.request_post(url.request_uri, options[:raw_data], @@connection.headers)
        result.body
      else
        request 'post', url, options
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
	'accountType' => 'HOSTED_OR_GOOGLE',
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
      def self.request(method, url, o={})
        options = {
          :form_data  => nil, 
          :query_hash => nil,
          :qsi        => '?'
        }.merge(o)

        url += hash_to_query_string(options[:query_hash], options[:qsi]) unless options[:query_hash].nil?
        url  = URI.parse(URI.escape(url))
        req  = if method == 'post'
          Net::HTTP::Post.new(url.request_uri, @@connection.headers)
        else
          Net::HTTP::Get.new(url.request_uri, @@connection.headers)
        end
        req.set_form_data(options[:form_data]) if options[:form_data]

        http   = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if url.port == 443
        result = http.start() { |conn| conn.request(req) }
  			result.body
      end

      # Converts a hash to a query string
      #
      # Usage:
      #   hash_to_query_string({:q => 'test', :num => 5}) # => '?q=test&num=5&'        
      #   hash_to_query_string({:q => 'test', :num => 5}, '&') # => '&q=test&num=5&'
      def self.hash_to_query_string(hash, initial_value="?")
        hash.inject(initial_value) { |qs, h| qs += "#{h[0]}=#{h[1]}&"; qs }
      end
      
      def extract_sid(body)
        matches = body.match(/SID=(.*)/)
        matches.nil? ? nil : matches[0].gsub('SID=', '')
      end
  end
end
