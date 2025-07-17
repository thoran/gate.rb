require_relative './lib/Gate/VERSION'

Gem::Specification.new do |spec|
  spec.name = 'gate.rb'

  spec.version = Gate::VERSION
  spec.date = '2025-07-17'

  spec.summary = "Access the Gate API with Ruby."
  spec.description = "Access the Gate API with Ruby."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'http://github.com/thoran/gate.rb'
  spec.license = 'Ruby'

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency('http.rb')
  spec.files = [
    'gate.rb.gemspec',
    'Gemfile',
    Dir['lib/**/*.rb'],
    'README.md',
    Dir['test/**/*.rb']
  ].flatten
  spec.require_paths = ['lib']
end
