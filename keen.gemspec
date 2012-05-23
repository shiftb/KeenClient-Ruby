# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "keen/version"

Gem::Specification.new do |s|
  s.name        = "keen"
  s.version     = Keen::VERSION
  s.authors     = ["Kyle Wild"]
  s.email       = ["kyle@keen.io"]
  s.homepage    = "https://github.com/keenlabs/KeenClient-Ruby"
  s.summary     = "A library for sending events to the keen.io API."
  s.description = "See the github repo or examples.rb for usage information."

  s.rubyforge_project = "keen"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  
  s.add_dependency('json', '>= 1.6.5')
  s.add_dependency('fakeweb', '>= 1.3.0')
  s.add_dependency('rspec', '>= 2.9.0')
  if RUBY_VERSION < "1.9"
    s.add_dependency('system_timer', '>= 1.2.4')
  end
  s.add_dependency('redis', '>= 2.2.2')

  # took these from Twilio library:
  # TODO clean this up.
  #s.add_development_dependency 'rake',    '~> 0.9.0'
  #s.add_development_dependency 'rspec',   '~> 2.6.0'
  #s.add_development_dependency 'fakeweb', '~> 1.3.0'
  #s.add_development_dependency 'rack',    '~> 1.3.0'
end
