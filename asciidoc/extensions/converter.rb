require 'tilt'
require 'tilt/slim'

class MyHtml5Converter < (Asciidoctor::Converter.for 'html5')
  register_for 'html5'

  LF = ?\n

  attr_accessor :doc
  attr_accessor :processed

  def convert_document(doc)
    logger.info "Converting a document: <#{doc.attributes['docfile']}>"

    self.doc = doc
    self.processed = super

    # if self.doc.attributes['docfile'].match(/index\.(html|adoc)$/)
    #   self.processed = insert_scroll(self.doc, self.processed)
    # end

    # There has to be a better way to determine if this is a "full" doc or an include
    unless self.doc.attributes['docdir'].match(/\b_include\b/)
      self.processed = render_header(self.doc, self.processed)
    end
    self.processed
  end

  def convert_ulist(node)
    result = []
    id_attribute = node.id ? %( id="#{node.id}") : ''
    div_classes = ['ulist', node.style, node.role].compact
    marker_checked = marker_unchecked = ''
    ul_classes = []
    if (checklist = node.option? 'checklist')
      div_classes.unshift div_classes.shift, 'checklist'
      ul_classes << 'checklist'
      if node.option? 'interactive'
        if @xml_mode
          marker_checked = '<input type="checkbox" data-item-complete="1" checked="checked"/> '
          marker_unchecked = '<input type="checkbox" data-item-complete="0"/> '
        else
          marker_checked = '<input type="checkbox" data-item-complete="1" checked> '
          marker_unchecked = '<input type="checkbox" data-item-complete="0"> '
        end
      elsif node.document.attr? 'icons', 'font'
        marker_checked = '<i class="fa fa-check-square-o"></i> '
        marker_unchecked = '<i class="fa fa-square-o"></i> '
      else
        marker_checked = '&#10003; '
        marker_unchecked = '&#10063; '
      end
    elsif node.style
      ul_classes << node.style
    end
    unless node.attributes['options'] && node.attributes['options']['nodiv']
      result << %(<div#{id_attribute} class="#{div_classes.join ' '}">)
    end
    result << %(<div class="title">#{node.title}</div>) if node.title?
    if node.attributes['options'] && node.attributes['options']['nodiv']
      result << %(<ul#{id_attribute} class="#{(div_classes + ul_classes).join(' ')}">)
    else
      result << %(<ul class="#{(ul_classes).join(' ')}">)
    end

    node.items.each do |item|
      if item.id
        result << %(<li id="#{item.id}"#{item.role ? %( class="#{item.role}") : ''}>)
      elsif item.role
        result << %(<li class="#{item.role}">)
      else
        result << '<li>'
      end
      if checklist && (item.attr? 'checkbox')
        if node.attributes['options'] && node.attributes['options']['nopara']
          result << %(#{(item.attr? 'checked') ? marker_checked : marker_unchecked}#{item.text})
        else
          result << %(<p>#{(item.attr? 'checked') ? marker_checked : marker_unchecked}#{item.text}</p>)
        end
      else
        if node.attributes['options'] && node.attributes['options']['nopara']
          result << %(#{item.text})
        else
          result << %(<p>#{item.text}</p>)
        end
      end
      result << item.content if item.blocks?
      result << '</li>'
    end

    result << '</ul>'
    result << '</div>' unless node.attributes['options'] && node.attributes['options']['nodiv']
    result.join LF
  end

  private

  def insert_scroll(doc, processed)
    parts = processed.partition(/<\/head>/)
    parts[0] + <<~JS + parts[1] + parts[2]
      <script>
        document.addEventListener('DOMContentLoaded',
          () => {
            let container = document.getElementsByClassName('post-list')[0]
            container.scroll({
              top: container.scrollHeight,
              behavior: "smooth",
            })
          }
        );
      </script>
    JS
  end

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
