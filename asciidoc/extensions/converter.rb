require 'tilt'
require 'tilt/slim'

class MyHtml5Converter < (Asciidoctor::Converter.for 'html5')
  register_for 'html5'

  def convert_document(doc)
    logger.info "Converting a document: <#{doc.attributes['docfile']}>"

    processed = super

    # There has to be a better way to determine if this is a "full" doc or an include
    unless doc.attributes['docdir'].match(/\b_include\b/)
      processed = render_header(doc, processed)
    end
  end

  private

  def render_header(doc, processed)
    template = Tilt.new('asciidoc/templates/docinfo-header.html.slim')
      .render(self, doctitle: doc.title, date: doc.attributes['date'])

    parts = processed.partition(/<body[^>]*>/)
    processed = parts[0] + parts[1] + template + parts[2]
  end
end
