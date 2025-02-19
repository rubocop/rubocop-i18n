# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'rubocop-i18n'
  spec.version       = '3.2.0'
  spec.authors       = ['Puppet', 'Brandon High', 'TP Honey', 'Helen Campbell']

  spec.summary       = 'RuboCop rules for i18n'
  spec.description   = 'RuboCop rules for detecting and autocorrecting undecorated strings for i18n (gettext and rails-i18n)'
  spec.homepage      = 'https://github.com/rubocop/rubocop-i18n'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'default_lint_roller_plugin' => 'RuboCop::I18n::Plugin'
  }

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '~> 1.72.1'
end
