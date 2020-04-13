Gem::Specification.new do |s|
  s.name     = 'full_request_logger'
  s.version  = '0.3.1'
  s.authors  = 'David Heinemeier Hansson'
  s.email    = 'david@basecamp.com'
  s.summary  = 'Make full request logs accessible via web UI'
  s.homepage = 'https://github.com/basecamp/full_request_logger'
  s.license  = 'MIT'

  s.required_ruby_version = '>= 2.6.0'

  s.add_dependency 'rails', '>= 5.0.0'
  s.add_dependency 'redis', '>= 4.0'

  s.add_development_dependency 'bundler', '~> 1.17'

  s.files      = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
end
