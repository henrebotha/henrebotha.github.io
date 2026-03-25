require 'asciidoctor/extensions'

# Defines the samp:[text] inline macro
# samp:[some text] → <samp>some text</samp>
class SampInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
  enable_dsl
  named :samp
  format :short

  def process parent, target, attrs
    create_inline_pass parent, "<samp>#{target}</samp>", {}
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
    create_inline_pass parent, "<var>#{target}</var>", {}
  end
end

Asciidoctor::Extensions.register { inline_macro VarInlineMacro }
