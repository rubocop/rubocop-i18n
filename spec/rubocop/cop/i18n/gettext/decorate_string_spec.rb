# frozen_string_literal: true

describe RuboCop::Cop::I18n::GetText::DecorateString, :config do
  before(:each) do
    @offenses = investigate(cop, source)
  end

  context 'decoration needed for string' do
    it_behaves_like 'a_detecting_cop', 'a = "A sentence that is not decorated."', '_', 'decorator is missing around sentence'
    it_behaves_like 'a_detecting_cop', 'thing("A sentence that is not decorated.")', '_', 'decorator is missing around sentence'
    it_behaves_like 'a_fixing_cop', 'thing("A sentence that is not decorated.")', 'thing(_("A sentence that is not decorated."))', 'thing'
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
    it_behaves_like 'accepts', 'memo["#{class_path}##{method}-#{source_line}"] += 1'
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
        line two\"", '_', 'decorator is missing around sentence'
    it_behaves_like 'a_detecting_cop', "b = \"line one.
        A sentence line two.\"", '_', 'decorator is missing around sentence'
  end

  RuboCop::Cop::I18n::GetText.supported_decorators.each do |decorator|
    context "#{decorator} already present" do
      it_behaves_like 'accepts', "#{decorator}('a string')"
      it_behaves_like 'accepts', "#{decorator} \"a string\""
      it_behaves_like 'accepts', "a = #{decorator}('a string')"
      it_behaves_like 'accepts', "#{decorator}(\"a %-5.2.s thing s string\")"
      it_behaves_like 'accepts', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\") % { group: group, detail: detail }"
      it_behaves_like 'accepts', "Log.warning #{decorator}(\"could not change to group %{group}: %{detail}\") %
                                            { group: #{decorator}(\"group\"), detail: #{decorator}(\"detail\") }"
    end

    context "#{decorator} around dstr" do
      it_behaves_like 'accepts', "a = #{decorator}(\"A sentence line one.
        line two\")"
      it_behaves_like 'accepts', "a = #{decorator}(\"line one.
        A sentence line two.\")"
    end
  end
end
