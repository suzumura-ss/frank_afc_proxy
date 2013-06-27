# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'frank_afc_proxy/version'

Gem::Specification.new do |spec|
  spec.name          = "frank_afc_proxy"
  spec.version       = FrankAfcProxy::VERSION
  spec.authors       = ["Toshiyuki Suzumura"]
  spec.email         = ["suz.labo@amail.plala.or.jp"]
  spec.description   = %q{Connect to FrankServer with iPhone USB cable via afc.}
  spec.summary       = %q{Connect to FrankServer with iPhone USB cable via afc.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "frank-cucumber", "~> 1.1.12"
  spec.add_dependency "io-afc"
  spec.add_dependency "daemon-spawn"
end
