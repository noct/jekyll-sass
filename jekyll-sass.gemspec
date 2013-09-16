# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jekyll-sass/version"

Gem::Specification.new do |s|
  s.name        = "jekyll-sass"
  s.version     = Jekyll::Sass::VERSION
  s.authors     = ["Jason Kozak"]
  s.email       = ["jay@noctal.com"]
  s.homepage    = "http://github.com/noct/jekyll-sass"
  s.summary     = %q{Sass CSS converter for Jekyll}
  s.description = %q{Convert Sass SCSS files to standard CSS files as part of your Jekyll build.}

  s.rubyforge_project = "jekyll-sass"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency('jekyll', [">= 0.10.0"])
  s.add_runtime_dependency('sass', [">= 3.0.0"])
  s.add_runtime_dependency('colorator', "~> 0.1")
end
