# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
$:.push File.dirname(__FILE__) + "/lib"
require 'ripl/readline/em'
 
Gem::Specification.new do |s|
  s.name        = "ripl-readline-em"
  s.version     = Ripl::Readline::Em::VERSION
  s.authors     = ["Patrick Mahoney"]
  s.email       = "pat@polycrystal.org"
  s.homepage    = "http://github.com/pmahoney/ripl-readline-em"
  s.summary     = "A ripl plugin to run readline within eventmachine"
  s.description =  "Run EventMachine code in a ripl shell asynchronously with readline editing and completion"
  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency 'ripl', '>= 0.4.2'
  s.add_dependency 'eventmachine'
  s.files = Dir.glob(%w[lib/**/*.rb [A-Z]*.{txt,rdoc}]) + %w{Rakefile .gemspec}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
