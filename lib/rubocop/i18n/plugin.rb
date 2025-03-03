# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module I18n
    # A plugin that integrates rubocop-i18n with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-i18n',
          version: VERSION,
          homepage: 'https://github.com/rubocop/rubocop-i18n',
          description: 'RuboCop rules for i18n.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end
    end
  end
end
