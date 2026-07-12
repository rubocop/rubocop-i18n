# frozen_string_literal: true

describe 'cop lazy loading' do # rubocop:disable RSpec/DescribeClass
  def run_script(source)
    Dir.mktmpdir do |dir|
      script = File.join(dir, 'script.rb')
      File.write(script, source)
      lib = File.expand_path('../lib', __dir__)
      output = `#{RbConfig.ruby} -I #{lib} #{script} 2>&1`
      raise "script failed:\n#{output}" unless $CHILD_STATUS.success?

      output
    end
  end

  it 'registers every cop file in both departments exactly once' do # rubocop:disable RSpec/ExampleLength
    cop_root = File.expand_path('../lib/rubocop/cop', __dir__)
    files = Dir[File.join(cop_root, 'i18n', '{gettext,rails_i18n}', '*.rb')].sort

    registered = %w[I18n/GetText I18n/RailsI18n].flat_map do |department|
      RuboCop::Cop::Registry.global.cops_for_department(department.to_sym).map do |cop|
        Object.const_source_location(cop.name).first
      end
    end

    expect(registered.sort).to eq(files)
  end

  it 'registers all cops without loading their files' do # rubocop:disable RSpec/ExampleLength
    output = run_script(<<~RUBY)
      require 'rubocop-i18n'

      registry = RuboCop::Cop::Registry.global
      loaded = $LOADED_FEATURES.grep(%r{/rubocop/cop/i18n/(gettext|rails_i18n)/})

      puts "registered=\#{registry.names.grep(%r{\\AI18n/}).size}"
      puts "loaded_cop_files=\#{loaded.size}"
    RUBY

    expect(output).to include('registered=6', 'loaded_cop_files=0')
  end

  it 'does not register a cop twice when its file is required directly' do # rubocop:disable RSpec/ExampleLength
    output = run_script(<<~RUBY)
      require 'rubocop-i18n'

      before = RuboCop::Cop::Registry.global.length
      require 'rubocop/cop/i18n/gettext/decorate_string'
      after = RuboCop::Cop::Registry.global.length

      puts "stable=\#{before == after}"
      puts "class=\#{RuboCop::Cop::Registry.global.find_by_cop_name('I18n/GetText/DecorateString')}"
    RUBY

    expect(output).to include('stable=true', 'class=RuboCop::Cop::I18n::GetText::DecorateString')
  end
end
