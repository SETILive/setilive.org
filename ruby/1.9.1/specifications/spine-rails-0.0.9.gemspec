# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "spine-rails"
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex MacCaw"]
  s.date = "2011-11-15"
  s.description = "This gem provides Spine for your Rails 3 application."
  s.email = ["info@eribium.org"]
  s.homepage = "http://rubygems.org/gems/spine-rails"
  s.require_paths = ["lib"]
  s.rubyforge_project = "spine-rails"
  s.rubygems_version = "1.8.10"
  s.summary = "Use Spine with Rails 3"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.1.0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 3.1.0"])
      s.add_dependency(%q<bundler>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.1.0"])
    s.add_dependency(%q<bundler>, [">= 0"])
  end
end
