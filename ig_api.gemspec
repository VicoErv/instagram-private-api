
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ig_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'ig_api'
  spec.version       = IgApi::VERSION
  spec.authors       = ['vicoerv']
  spec.email         = ['vicoerv@gmail.com']

  spec.summary       = 'Instagram private api'
  spec.description   = 'implemented from huttarichard/instagram-private-api'
  spec.homepage      = 'http://www.vicoervanda.com'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'multipart-post', '~> 2.0.0'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'rspec', '~> 3.0'
end
