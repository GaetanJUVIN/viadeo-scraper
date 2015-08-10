#encoding: utf-8

##
## viadeo-scraper.gemspec
## Gaetan JUVIN 08/07/2015
##

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'viadeo-scraper/version'

Gem::Specification.new do |spec|
  spec.name          = 'viadeo-scraper'
  spec.authors       = ['Gaëtan JUVIN']
  spec.email         = ['gaetanjuvin@gmail.com']
  spec.version       = Viadeo::Scraper::VERSION
  spec.description   = %q{Scrapes the viadeo profile}
  spec.summary       = %q{Scrapes the viadeo public profile page is given it scrapes the entire page and converts into an object}
  spec.homepage      = 'https://github.com/GaetanJUVIN/viadeo-scraper'

  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency %q<mechanize>, '~> 0'
end
