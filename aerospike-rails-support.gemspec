Gem::Specification.new do |gem|
  gem.name        = 'aerospike-rails-support'
  gem.version     = '0.1.1'
  gem.date        = '2015-09-28'
  gem.summary     = 'Provide Aerospike Sub Storage Service for Rails'
  gem.description = 'Provide Aerospike Sub Storage Service for Rails as cache and session store'
  gem.authors     = ['Jiung Jeong']
  gem.email       = 'ethernuiel@sanultari.com'
  gem.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  gem.license       = 'MIT'

  gem.add_dependency 'aerospike', '~> 1.0', '>= 1.0.9'
  gem.add_dependency 'hashie', '~> 3.4', '>= 3.4.2'
  
  gem.add_development_dependency 'activesupport', '~> 4.2', '>= 4.2.3'
  gem.add_development_dependency 'actionpack', '~> 4.2', '>= 4.2.3'
  gem.add_development_dependency 'rake', '~> 10.4', '>= 10.4.2'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2', '>= 0.2.4'
  gem.add_development_dependency 'bundler', '~> 1.8', '>= 1.8.2'
  gem.add_development_dependency 'rspec', '~> 3.3'
end
