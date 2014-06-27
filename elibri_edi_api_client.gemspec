# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elibri_edi_api_client/version'

Gem::Specification.new do |spec|
  spec.name          = "elibri_edi_api_client"
  spec.version       = ElibriEdiApiClient::VERSION
  spec.authors       = ["Piotr Romańczuk", "Tomasz Meka"]
  spec.email         = ["p.romanczuk@elibri.com.pl", "tomek@elibri.com.pl"]
  spec.description   = %q{A client for elibri EDI API}
  spec.summary       = %q{A client for elibri EDI API}
  spec.homepage      = "https://www.elibri.com.pl"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "faraday"
end
