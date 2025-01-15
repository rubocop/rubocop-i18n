# frozen_string_literal: true

describe RuboCop::Cop::I18n::RailsI18n::DecorateStringFormattingUsingInterpolation, :config do
  before(:each) do
    @offenses = investigate(cop, source)
  end

  RuboCop::Cop::I18n::RailsI18n.supported_decorators.each do |decorator|
    error_message = "function, message key string should not contain \#{} formatting"

    context "#{decorator} decoration not used" do
      it_behaves_like 'accepts', 'thing("a \#{true} that is not decorated")'
    end

    context "#{decorator} decoration used but strings contain no \#{}" do
      it_behaves_like 'accepts', "#{decorator}('a.string')"
      it_behaves_like 'accepts', "#{decorator} 'a.string'"
      it_behaves_like 'accepts', "#{decorator}(\"a.string\")"
      it_behaves_like 'accepts', "Log.warning #{decorator}(\"a.string.%{status}\") % { status: 'done' }"
    end

    context "#{decorator} decoration with formatting" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a.\#{true}\")", 't', error_message
    end

    context "#{decorator} decoration with multiple interpolations" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a.\#{true}.\#{false}\")", 't', error_message
      it_behaves_like 'a_detecting_cop', "#{decorator} \"a.\#{true}.\#{false}\"", 't', error_message
    end

    context "#{decorator} decoration with interpolation on second string" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a.string\" + \"\#{true}.\#{false}\")", 't', error_message
    end

    context "#{decorator} decoration with a constant and then an interplation string" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(CONSTANT, \"a \#{true}\")", 't', error_message
    end
  end
end
