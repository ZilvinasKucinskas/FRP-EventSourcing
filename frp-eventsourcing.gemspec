# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "frp-eventsourcing/version"

Gem::Specification.new do |spec|
  spec.name          = "frp-eventsourcing"
  spec.version       = FrpEventsourcing::VERSION
  spec.authors       = ["Zilvinas"]
  spec.email         = ["zil.kucinskas@gmail.com"]

  spec.summary       = %q{A library to do Functional Reactive Programming with EventSourcing in Ruby}
  spec.description   = %q{Functional Reactive Programming with EventSourcing in Ruby}
  spec.homepage      = "https://github.com/ZilvinasKucinskas/FRP-EventSourcing"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", ">= 4.0.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency "activerecord", ">= 4.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner", "~> 1.6"
end
