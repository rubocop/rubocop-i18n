# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/i18n'
require_relative 'rubocop/i18n/inject'

RuboCop::I18n::Inject.defaults!

require_relative 'rubocop/cop/i18n_cops'
