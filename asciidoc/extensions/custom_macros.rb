require 'asciidoctor/extensions'

# Defines the samp:[text] inline macro
# samp:[some text] → <samp>some text</samp>
class SampInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
  enable_dsl
  named :samp
  format :short

  def process parent, target, attrs
    create_inline_pass parent, <<~HTML.chomp, {}
      <samp>#{target}</samp>
    HTML
  end
end

Asciidoctor::Extensions.register { inline_macro SampInlineMacro }

# Defines the var:[text] inline macro
# var:[some text] → <var>some text</var>
class VarInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
  enable_dsl
  named :var
  format :short

  def process parent, target, attrs
    create_inline_pass parent, <<~HTML.chomp, {}
      <var>#{target}</var>
    HTML
  end
end

Asciidoctor::Extensions.register { inline_macro VarInlineMacro }
