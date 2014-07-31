# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atomic_arrays/version'

Gem::Specification.new do |spec|
  spec.name          = "atomic_arrays"
  spec.version       = AtomicArrays::VERSION
  spec.authors       = ["Joseph"]
  spec.email         = ["joseph.cs.ritchie@gmail.com"]
  spec.summary       = %q{ActiveRecord extension for atomic operations on PostgreSQL arrays.}
  spec.description   = %q{AtomicArrays is a lightweight gem that aims to assist ActiveRecord
                          with PostgreSQL array operations by offering a couple simple methods
                          to update arrays in the database and the instance that it is called on.
                          These methods are atomic in nature because they update the arrays in
                          the database without relying on the current object's instantiated arrays.}
  spec.homepage      = "https://github.com/twincharged/atomic_arrays"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", ">= 10.3.2"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "pg", ">= 0.17.1"

  spec.add_runtime_dependency "activerecord", ">= 4.0"
end
