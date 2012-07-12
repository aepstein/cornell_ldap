# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cornell_ldap/version"

Gem::Specification.new do |s|
  s.name        = "cornell_ldap"
  s.version     = CornellLdap::VERSION
  s.authors     = ["Ari Epstein"]
  s.email       = ["aepstein607@gmail.com"]
  s.homepage    = "http://github.com/aepstein/cornell_ldap"
  s.summary     = %q{Lightweight LDAP abstraction library to work Cornell's particular structure}
  s.description = %q{Using ActiveLdap, this library provides an easy interface for communicating with the Cornell University LDAP directory.  Use of this directory is restricted to purposes authorized by the university.}

  s.rubyforge_project = "cornell_ldap"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_dependency 'net-ldap'
end

