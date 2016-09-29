# -*- encoding: utf-8 -*-
$:.push File.join(File.dirname(__FILE__), 'lib')
require "rhino/version"

Gem::Specification.new do |s|
  s.name        = "rhino"
  s.version     = Rhino::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kevin Sylvestre"]
  s.email       = ["kevin@ksylvest.com"]
  s.executables = ["rhino"]
  s.homepage    = "https://github.com/ksylvest/rhino"
  s.summary     = "A web server written for fun."
  s.description = "This should probably never be used unless you are feeling lucky."
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(README.rdoc LICENSE Gemfile)

  s.add_dependency "slop"
  s.add_dependency "rack"
  s.add_development_dependency "bundler"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
