require 'tilt'
require 'tilt/slim'

class MyHtml5Converter < (Asciidoctor::Converter.for 'html5')
  register_for 'html5'

  attr_accessor :doc
  attr_accessor :processed

  def convert_document(doc)
    logger.info "Converting a document: <#{doc.attributes['docfile']}>"

    self.doc = doc
    self.processed = super

    # There has to be a better way to determine if this is a "full" doc or an include
    unless self.doc.attributes['docdir'].match(/\b_include\b/)
      self.processed = render_header(self.doc, self.processed)
    end
    self.processed
  end

  private

  def render_header(doc, processed)
    template = Tilt.new('asciidoc/templates/docinfo-header.html.slim')
      .render(
        self,
        doctitle: doc.title,
        date: doc.attributes['date'],
        updated: doc.attributes['updated']
      )

    # Split the HTML where the <body> starts
    parts = processed.partition(/<body[^>]*>/)
    # Insert our rendered header at the very beginning of the <body>
    parts[0] + parts[1] + template + parts[2]
  end

  def process_history
    logger.info "Processing update history for #{self.doc}"

    doc = self.doc

    updated = doc.attributes['updated'].scan(/(\d{4}-\d{2}-\d{2} \d{2}:\d{2} \+\d{4}) =&gt; '([^']*)'/).to_a

    (
      [[doc.attributes['date'], 'Publish article']] + updated
    ).sort

    # require 'pry'
    # binding.pry
  end

  def format_html_time(time)
    <<~HTML.chomp
      <time>#{time}</time>
    HTML
  end
end
