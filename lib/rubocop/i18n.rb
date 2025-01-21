# frozen_string_literal: true

module RuboCop
  # RuboCop I18n project namespace
  module I18n
    PROJECT_ROOT = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join('config', 'default.yml').freeze

    private_constant(:CONFIG_DEFAULT, :PROJECT_ROOT)
  end
end
