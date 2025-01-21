# frozen_string_literal: true

describe RuboCop::Cop::I18n::RailsI18n::DecorateString, :config do
  before do
    @offenses = investigate(cop, source)
  end

  context 'decoration needed for string' do
    it_behaves_like 'a_detecting_cop', 'a = "A sentence that is not decorated."', 't', 'decorator is missing around sentence'
    it_behaves_like 'a_detecting_cop', 'thing("A sentence that is not decorated.")', 't', 'decorator is missing around sentence'
  end

  context 'decoration not needed for string' do
    it_behaves_like 'accepts', "'keyword'"
    # a regexp is a string
    it_behaves_like 'accepts', '@regexp = /[ =]/'
    it_behaves_like 'accepts', 'Dir[File.dirname(__FILE__) + "/parser/compiler/catalog_validator/*.rb"].each { |f| require f }'
    it_behaves_like 'accepts', 'stream.puts "#@version\n" if @version'
    it_behaves_like 'accepts', '
          f.puts(<<-YAML)
            ---
            :tag: yaml
            :yaml:
               :something: #{variable}
          YAML'
  end

  context 'decoration not needed for a hash key' do
    # a string as an hash key is ok
    it_behaves_like 'accepts', 'memo["#{class_path}##{method}-#{source_line}"] += 1' # rubocop:disable Lint/InterpolationCheck
  end

  context 'string with invalid UTF-8' do
    it_behaves_like 'accepts', '
        STRING_MAP = {
      Encoding::UTF_8 => "\uFFFD",
      Encoding::UTF_16LE => "\xFD\xFF".force_encoding(Encoding::UTF_16LE),
    }'
  end

  context 'decoration missing for dstr' do
    it_behaves_like 'a_detecting_cop', "b = \"A sentence line one.
        line two\"", 't', 'decorator is missing around sentence'
    it_behaves_like 'a_detecting_cop', "b = \"line one.
        A sentence line two.\"", 't', 'decorator is missing around sentence'
  end

  RuboCop::Cop::I18n::RailsI18n.supported_decorators.each do |decorator|
    context "#{decorator} already present" do
      it_behaves_like 'accepts', "#{decorator}('a string')"
      it_behaves_like 'accepts', "#{decorator} \"a string\""
      it_behaves_like 'accepts', "a = #{decorator}('a string')"
      it_behaves_like 'accepts', "#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'accepts', "Log.warning #{decorator}(\"could not change to group %<group>: %<detail>\", group: group, detail: detail)"
      it_behaves_like 'accepts', "Log.warning #{decorator}(\"could not change to group %<group>: %<detail>\",
                                            group: #{decorator}(\"group\"), detail: #{decorator}(\"detail\"))"
    end

    context "#{decorator} around dstr" do
      it_behaves_like 'accepts', "a = #{decorator}(\"A sentence line one.
        line two\")"
      it_behaves_like 'accepts', "a = #{decorator}(\"line one.
        A sentence line two.\")"
    end

    context "I18n.#{decorator} already present" do
      it_behaves_like 'accepts', "I18n.#{decorator}('a string')"
      it_behaves_like 'accepts', "I18n.#{decorator} \"a string\""
      it_behaves_like 'accepts', "a = I18n.#{decorator}('a string')"
      it_behaves_like 'accepts', "I18n.#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'accepts', "Log.warning I18n.#{decorator}(\"could not change to group %<group>: %<detail>\", group: group, detail: detail)"
      it_behaves_like 'accepts', "Log.warning I18n.#{decorator}(\"could not change to group %<group>: %<detail>\",
                                            group: I18n.#{decorator}(\"group\"), detail: I18n.#{decorator}(\"detail\"))"
    end

    context "I18n.#{decorator} around dstr" do
      it_behaves_like 'accepts', "a = I18n.#{decorator}(\"A sentence line one.
        line two\")"
      it_behaves_like 'accepts', "a = I18n.#{decorator}(\"line one.
        A sentence line two.\")"
    end

    context "SomeOtherMod.#{decorator} is used" do
      it_behaves_like 'accepts', "SomeOtherMod.#{decorator}('a string')"
      it_behaves_like 'accepts', "SomeOtherMod.#{decorator} \"a string\""
      it_behaves_like 'accepts', "a = SomeOtherMod.#{decorator}('a string')"
      it_behaves_like 'accepts', "SomeOtherMod.#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'accepts', "Log.warning SomeOtherMod.#{decorator}(\"could not change to group %<group>: %<detail>\", group: group, detail: detail)"
      it_behaves_like 'accepts', "Log.warning SomeOtherMod.#{decorator}(\"could not change to group %<group>: %<detail>\",
                                            group: SomeOtherMod.#{decorator}(\"group\"), detail: SomeOtherMod.#{decorator}(\"detail\"))"

      it_behaves_like 'a_detecting_cop', "SomeOtherMod.#{decorator}('Some sentence like text.')", decorator, 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "SomeOtherMod.#{decorator} \"Some sentence like text.\"", decorator, 'decorator is missing around sentence'
    end

    context "SomeOtherMod.#{decorator} around dstr" do
      it_behaves_like 'a_detecting_cop', "a = SomeOtherMod.#{decorator}(\"A sentence line one.
        line two\")", decorator, 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "a = SomeOtherMod.#{decorator}(\"line one.
        A sentence line two.\")", decorator, 'decorator is missing around sentence'

      it_behaves_like 'accepts', "a = SomeOtherMod.#{decorator}(\"line one.
        a sentence line two\")"
    end
  end

  context 'when ignoring raised exceptions' do
    let(:config) do
      RuboCop::Config.new('I18n/RailsI18n/DecorateString' => { 'IgnoreExceptions' => true })
    end

    %w[fail raise].each do |type|
      it_behaves_like 'accepts', "#{type} \"A sentence that is not decorated.\""
      it_behaves_like 'accepts', "#{type} StandardError, \"A sentence that is not decorated.\""
      it_behaves_like 'accepts', "#{type} StandardError.new(\"A sentence that is not decorated.\")"
    end
  end

  context 'when configuring a different regex' do
    let(:config) do
      RuboCop::Config.new('I18n/RailsI18n/DecorateString' => { 'Regexp' => '^test-test-test$' })
    end

    it_behaves_like 'accepts', "not_t('A sentence.')"
    it_behaves_like 'a_detecting_cop', "not_t('test-test-test')", 't', 'decorator is missing around sentence'
  end

  context 'when string type' do
    let(:config) do
      RuboCop::Config.new('I18n/RailsI18n/DecorateString' => { 'EnforcedSentenceType' => type })
    end

    context 'is sentence' do
      let(:type) { 'sentence' }

      it_behaves_like 'accepts', "not_t('word')"
      it_behaves_like 'accepts', "not_t('a fragment')"
      it_behaves_like 'accepts', "not_t('A sentence fragment')"
      it_behaves_like 'accepts', "not_t('a sentence fragment.')"
      it_behaves_like 'a_detecting_cop', "not_t('A real sentence.')", 't', 'decorator is missing around sentence'
    end

    context 'is fragmented sentence' do
      let(:type) { 'fragmented_sentence' }

      it_behaves_like 'accepts', "not_t('word')"
      it_behaves_like 'accepts', "not_t('a fragment')"
      it_behaves_like 'a_detecting_cop', "not_t('A sentence fragment')", 't', 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "not_t('a sentence fragment.')", 't', 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "not_t('A real sentence.')", 't', 'decorator is missing around sentence'
    end

    context 'is fragment' do
      let(:type) { 'fragment' }

      it_behaves_like 'accepts', "not_t('word')"
      it_behaves_like 'a_detecting_cop', "not_t('a fragment')", 't', 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "not_t('A sentence fragment')", 't', 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "not_t('a sentence fragment.')", 't', 'decorator is missing around sentence'
      it_behaves_like 'a_detecting_cop', "not_t('A real sentence.')", 't', 'decorator is missing around sentence'
    end
  end
end
