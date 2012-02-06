# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "spine/version"

Gem::Specification.new do |s|
  s.name        = "spine"
  s.version     = Spine::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nicolaas"]
  s.email       = ["nicolaas@catosylus.com"]
  s.homepage    = ""
  s.summary     = %q{My Summary}
  s.description = %q{The description}

  s.rubyforge_project = "spine"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
