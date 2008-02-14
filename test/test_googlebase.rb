require File.dirname(__FILE__) + '/test_helper.rb'

# I am fully aware these are lacking. Haven't had the time to figure out best way to test this since it is in essence a hack.

class TestGooglebase < Test::Unit::TestCase

  def setup
  end
  
  def test_should_make_http_get_request
    html = Google::Base.get('http://www.google.com/reader/user-info')
    assert html =~ /webgroup@nd\.edu/
  end
  
  def test_should_make_https_get_request
    html = Google::Base.get('https://www.google.com:443/analytics/home/')
    assert html =~ /webgroup\.nd\.edu/
  end
  
  def test_should_make_http_post_request
    
  end
  
  def test_should_make_https_post_request
    
  end
  
  def test_should_make_http_post_request_with_raw_data
    
  end
  
  def test_should_make_https_post_request_with_raw_data
    
  end
end