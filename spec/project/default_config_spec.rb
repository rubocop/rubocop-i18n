# frozen_string_literal: true

RSpec.describe 'config/default.yml' do
  subject(:default_config) do
    RuboCop::ConfigLoader.load_yaml_configuration('config/default.yml')
  end

  let(:primary_namespace) { 'I18n' }

  let(:namespaces) do
    { 'gettext' => "#{primary_namespace}/GetText", 'rails_i18n' => "#{primary_namespace}/RailsI18n" }
  end

  let(:cop_names) do
    namespaces.flat_map do |directory, namespace|
      Pathname.glob("lib/rubocop/cop/i18n/#{directory}/*.rb").map do |file|
        cop_name = file.basename('.rb').to_s.gsub(/(^|_)(.)/) { Regexp.last_match(2).upcase }
        "#{namespace}/#{cop_name}"
      end
    end
  end

  let(:config_keys) do
    cop_names + namespaces.values + [primary_namespace]
  end

  def cop_configuration(config_key)
    cop_names.map do |cop_name|
      cop_config = default_config[cop_name]

      cop_config.fetch(config_key) do
        raise "Expected #{cop_name} to have #{config_key} configuration key"
      end
    end
  end

  it 'has configuration for all cops and amendments' do
    expect(default_config.keys).to match_array(config_keys)
  end

  it 'sorts configuration keys alphabetically with nested namespaces last' do
    i18n_keys = default_config.keys.select { |key| key.start_with?(primary_namespace) }
    namespaced_i18n_keys = i18n_keys.select { |key| key.start_with?(*(namespaces.values - [primary_namespace])) }
    expected = i18n_keys.sort_by { |key| "#{namespaced_i18n_keys.include?(key) ? 1 : 0} #{key}" }

    i18n_keys.each_with_index { |key, idx| expect(key).to eq expected[idx] }
  end

  it 'includes a valid Enabled for every cop' do
    expect(cop_configuration('Enabled'))
      .to all be(true).or(be(false)).or(eq('pending'))
  end
end
