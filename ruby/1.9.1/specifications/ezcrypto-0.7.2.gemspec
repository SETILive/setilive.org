# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ezcrypto"
  s.version = "0.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pelle Braendgaard"]
  s.date = "2009-03-10"
  s.description = "Makes it easier and safer to write crypto code."
  s.email = "pelle@stakeventures.com"
  s.extra_rdoc_files = ["CHANGELOG", "README.rdoc", "README_ACTIVE_CRYPTO", "README_DIGITAL_SIGNATURES"]
  s.files = ["CHANGELOG", "README.rdoc", "README_ACTIVE_CRYPTO", "README_DIGITAL_SIGNATURES"]
  s.homepage = "http://ezcrypto.rubyforge.org"
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = "ezcrypto"
  s.rubygems_version = "1.8.10"
  s.summary = "Simplified encryption library."

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
