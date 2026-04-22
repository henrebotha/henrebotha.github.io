require 'asciidoctor/extensions'

def find_posts
  Dir.glob('src/posts/*.adoc')
    .reverse
    .map.with_index do |p, i|
      title = File.open(p, &:readline).gsub(/^= /, '').strip
      date = p.gsub(/^.*(\d{4}-\d{2}-\d{2}).*$/, '\1')
      date + (i == 0 ? ' (latest): ' : ': ') + 'xref:' + p.gsub(/$/, '[' + title + ']').gsub(/^src\//, '')
    end.reverse
end

Asciidoctor::Extensions.register do
  tree_processor do
    process do |doc|
      singleton_class.include Asciidoctor::Logging

      if doc.attr? 'generate-index'
        logger.info "Generating index for #{doc}"
        posts = find_posts()

        list = Asciidoctor::List.new(doc, :ulist, attributes: { 'role' => 'tnum' })
        list.style = 'no-bullet'
        posts.each { |p| list << Asciidoctor::ListItem.new(list, p) }

        doc.blocks << list
      end
    end
  end
end
