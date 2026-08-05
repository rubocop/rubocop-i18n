# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      # The Rails I18n module contains cops used to lint and enforce the use of strings
      # in rails applications that want to use the I18n gem.
      module RailsI18n
        extend LazyLoader

        register_cop :DecorateString, "#{__dir__}/rails_i18n/decorate_string"
        register_cop :DecorateStringFormattingUsingInterpolation,
                     "#{__dir__}/rails_i18n/decorate_string_formatting_using_interpolation"

        def self.supported_decorators
          %w[
            t
            t!
            translate
            translate!
          ].freeze
        end

        def self.supported_decorator?(decorator_name)
          supported_decorators.include?(decorator_name)
        end
      end
    end
  end
end
