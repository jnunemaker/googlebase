

Gem::Specification.new do |s|
  s.name        = "googlebase"
  s.version     = "0.2.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Nunemaker"]
  s.email       = ["nunemaker@gmail.com"]
  s.homepage    = "https://github.com/jnunemaker/googlebase"
  s.summary     = "Base class which handles authentication and requests for google services"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "googlebase"

  s.files        = Dir.glob("{lib}/**/*") + %w(License.txt README.txt Manifest.txt History.txt)
  s.require_path = 'lib'
end