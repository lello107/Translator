# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Translator/version'

Gem::Specification.new do |spec|
  spec.name          = "Translator"
  spec.version       = Translator::VERSION
  spec.authors       = ["Marcello Romani"]
  spec.email         = ["lello107@hotmail.com"]

  spec.summary       = %q{Translator V12 per Immagine}
  spec.description   = %q{Rules sets to create onair playlist}
  spec.homepage      = "https://github.com/lello107"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
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

  spec.add_development_dependency "bundler"#, "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "ostruct"
end
