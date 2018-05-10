# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marfusha/version'

Gem::Specification.new do |spec|
  spec.name          = "marfusha"
  spec.version       = Marfusha::VERSION
  spec.authors       = ["Uchio KONDO"]
  spec.email         = ["udzura@udzura.jp"]

  spec.summary       = %q{A containers orchestrator aiming to the space!}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/udzura/marfusha"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ffi-rzmq"
  spec.add_runtime_dependency "serverengine"
  spec.add_runtime_dependency "slop"
  spec.add_runtime_dependency "celluloid-io"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
