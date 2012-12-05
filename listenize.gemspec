# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'listenize/version'

Gem::Specification.new do |gem|
  gem.name          = "listenize"
  gem.version       = Listenize::VERSION
  gem.authors       = ["Shota Fukumori (sora_h)"]
  gem.email         = ["sorah@tubusu.net"]
  gem.description   = %q{可聴化 - Kachôka, make <something> listenable}
  gem.summary       = %q{Do 可聴化 (Kachôka, make <something> listenable), listen to everything.}
  gem.homepage      = "https://github.com/sorah/listenize"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "sinatra"
  gem.add_dependency "thin"
  gem.add_dependency "sass"
  gem.add_dependency "haml"
  gem.add_dependency "coffee-script"
  gem.add_dependency "sprockets"
end
