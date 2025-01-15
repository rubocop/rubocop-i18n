# frozen_string_literal: true

describe RuboCop::Cop::I18n::GetText::DecorateFunctionMessage, :config do
  before do
    @offenses = investigate(cop, source)
  end

  RuboCop::Cop::I18n::GetText.supported_methods.each do |function|
    context "#{function} with undecorated double-quote message" do
      it_behaves_like 'a_detecting_cop', "#{function}(\"a string\")", function, 'message string should be decorated'
      it_behaves_like 'a_fixing_cop', "#{function}(\"a string\")", "#{function}(_(\"a string\"))", function
      it_behaves_like 'accepts', "#{function}(_(\"a string\"))", function
    end

    context "#{function} with undecorated single-quoted message" do
      it_behaves_like 'a_detecting_cop', "#{function}('a string')", function, 'message string should be decorated'
      it_behaves_like 'a_fixing_cop', "#{function}('a string')", "#{function}(_('a string'))", function
      it_behaves_like 'accepts', "#{function}(_('a string'))", function
    end

    context "#{function} with undecorated constant & message" do
      it_behaves_like 'a_detecting_cop', "#{function}(CONSTANT, 'a string')", function, 'message string should be decorated'
      it_behaves_like 'a_fixing_cop', "#{function}(CONSTANT, 'a string')", "#{function}(CONSTANT, _('a string'))", function
      it_behaves_like 'accepts', "#{function}(CONSTANT, _('a string'))", function
    end

    context "#{function} with multiline message" do
      it_behaves_like 'a_detecting_cop', "#{function} 'multi '\\\n 'line'", function, 'message should not be a multi-line string'
    end

    context "#{function} with concatenated message" do
      it_behaves_like 'a_detecting_cop', "fail 'this' + 'string' + 'is' + 'concatenated'", function, 'message should not be a concatenated string'
    end

    context "#{function} with interpolated string" do
      it_behaves_like 'a_detecting_cop', "#{function}(\"a string \#{var}\")", function, 'message should use correctly formatted interpolation'
      # it_behaves_like 'a_fixing_cop', "#{function}(\"a string \#{var}\")", "#{function}(_(\"a string %{value0}\") % { value0: var, })", function
      it_behaves_like 'accepts', "#{function}(_(\"a string %{value0}\")) % { value0: var, }", function
      it_behaves_like 'accepts', "#{function}(N_(\"a string %s\"))", function
    end

    context "#{function} message not decorated, but does not hit interpolation / concatenation / multi-line / simple-string" do
      it_behaves_like 'a_detecting_cop', "fail print('kittens')", function, 'message should be decorated'
    end

    RuboCop::Cop::I18n::GetText.supported_decorators.each do |decorator|
      context "#{function} with the #{decorator} decorator" do
        it_behaves_like 'accepts', "#{function}(#{decorator}(\"a string\"))", function
        it_behaves_like 'accepts', "#{function}(#{decorator}('a string'))", function
        it_behaves_like 'accepts', "#{function}(CONSTANT, #{decorator}('a string'))", function
        it_behaves_like 'accepts', "#{function}(#{decorator}(\"a string %{value0}\")) % { value0: var, }", function
      end
    end
  end
  context 'real life examples,' do
    context 'message is multiline with interpolated' do
      let(:source) { "raise(Puppet::ParseError, \"mysql_password(): Wrong number of arguments \" \\\n \"given (\#{args.size} for 1)\")" }

      it 'has the correct error message' do
        expect(@offenses[0]).not_to be_nil
        expect(@offenses[0].message).to match(/message should not be a multi-line string/)
        expect(@offenses[0].message).to match(/message should use correctly formatted interpolation/)
      end

      it 'has the correct number of offenses' do
        expect(@offenses.size).to eq(1)
      end

      it 'autocorrects', :broken do
        corrected = autocorrect_source("raise(Puppet::ParseError, \"mysql_password(): Wrong number of arguments \" \\ \"given (\#{args.size} for 1)\")")
        expect(corrected).to eq('raise(Puppet::ParseError, _("a string %{value0}") % { value0: var, })')
      end
    end
  end
end
