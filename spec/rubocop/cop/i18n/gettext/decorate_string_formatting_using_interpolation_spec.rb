# frozen_string_literal: true

describe RuboCop::Cop::I18n::GetText::DecorateStringFormattingUsingInterpolation, :config do
  before(:each) do
    @offenses = investigate(cop, source)
  end

  RuboCop::Cop::I18n::GetText.supported_decorators.each do |decorator|
    error_message = "function, message string should not contain \#{} formatting"

    context "#{decorator} decoration not used" do
      it_behaves_like 'accepts', 'thing("a \#{true} that is not decorated")'
    end

    context "#{decorator} decoration used but strings contain no \#{}" do
      it_behaves_like 'accepts', "#{decorator}('a string')"
      it_behaves_like 'accepts', "#{decorator} 'a string'"
      it_behaves_like 'accepts', "#{decorator}(\"a string\")"
      it_behaves_like 'accepts', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\") % { group: group, detail: detail }"
    end

    context "#{decorator} decoration with formatting" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a \#{true}\")", '_', error_message
    end

    context "#{decorator} decoration with multiple interpolations" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a \#{true} \#{false}\")", '_', error_message
      it_behaves_like 'a_detecting_cop', "#{decorator} \"a \#{true} \#{false}\"", '_', error_message
    end

    context "#{decorator} decoration with interpolation on second string" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(\"a string\" + \"\#{true} \#{false}\")", '_', error_message
    end

    context "#{decorator} decoration with a constant and then an interplation string" do
      it_behaves_like 'a_detecting_cop', "#{decorator}(CONSTANT, \"a \#{true}\")", '_', error_message
    end
  end
end
