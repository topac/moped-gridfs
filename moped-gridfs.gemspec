lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moped/gridfs/version'

Gem::Specification.new do |spec|
  spec.name          = "moped-gridfs"
  spec.version       = Moped::GridFS::VERSION
  spec.authors       = ["topac"]
  spec.email         = ["topac@users.noreply.github.com"]
  spec.summary       = %q{mongoDB GridFS implementation for Moped}
  spec.description   = %q{mongoDB GridFS implementation for Moped}
  spec.homepage      = "https://www.github.com/topac/moped-gridfs"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("moped")

  spec.add_development_dependency("bundler", "~> 1.6")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("pry")
end
