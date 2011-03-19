# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "search_magic/version"

Gem::Specification.new do |s|
  s.name        = "search_magic"
  s.version     = SearchMagic::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Bowers"]
  s.email       = ["joshua.bowers+code@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{SearchMagic provides scoped full text search and sort capabilities to Mongoid documents}
  s.description = %q{Adds scopes to a Mongoid document providing search and sort capabilities on arbitrary fields and associations.}
  
  s.add_dependency("mongoid", ">= 2.0.0.rc.7")
  s.add_development_dependency("rspec")
  s.add_development_dependency("database_cleaner")
  s.add_development_dependency("bson_ext")

  s.rubyforge_project = "search_magic"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
