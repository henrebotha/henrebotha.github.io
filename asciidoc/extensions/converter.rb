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

    doc.attr?('date') ? insert_time(processed, doc.attr('date')) : processed
  end

  private

  def render_header(doc, processed)
    template = Tilt.new('asciidoc/templates/docinfo-header.html.slim').render(self, doctitle: doc.title)

    parts = processed.partition(/<body[^>]*>/)
    processed = parts[0] + parts[1] + template + parts[2]
  end

  def insert_time(processed, date)
    header_regex = %r{(<header[^>]*>)(.*)</header>}m
    has_header = processed.match(header_regex)

    return processed unless has_header

    header = has_header[0]
    header_element = has_header[1]
    header_content = has_header[2]
    new_header = %(#{header_element}#{header_content}<time class="posted-at">#{date}</time></header>)

    processed.gsub(header, new_header)
  end
end
