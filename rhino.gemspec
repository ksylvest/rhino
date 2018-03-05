
$:.push File.join(File.dirname(__FILE__), 'lib')
require 'rhino/version'

Gem::Specification.new do |spec|
  spec.name        = 'rhino'
  spec.version     = Rhino::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ['Kevin Sylvestre']
  spec.email       = ['kevin@ksylvest.com']
  spec.executables = ['rhino']
  spec.homepage    = 'https://github.com/ksylvest/rhino'
  spec.summary     = 'A web server written for fun.'
  spec.description = 'This should probably never be used.'
  spec.files       = Dir.glob('{bin,lib}/**/*') + %w[README.md LICENSE Gemfile]

  spec.add_dependency 'rack'
  spec.add_dependency 'slop'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
