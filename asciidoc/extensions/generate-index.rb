require 'asciidoctor/extensions'

def find_posts
  Dir.glob('src/posts/*.adoc')
    .reverse.map.with_index do |p, i|
      title = File.open(p, &:readline).gsub(/^= /, '').strip
      date = p.gsub(/^.*(\d{4}-\d{2}-\d{2}).*$/, '\1')
      date + (i == 0 ? ' (latest): ' : ': ') + 'xref:' + p.gsub(/$/, '[' + title + ']').gsub(/^src\//, '')
    end.reverse
end

Asciidoctor::Extensions.register do
  tree_processor do
    process do |doc|
      if doc.attr? 'generate-index'
        posts = find_posts()

        list = Asciidoctor::List.new(doc, :ulist, attributes: { 'role' => 'tnum' })
        list.style = 'no-bullet'
        posts.each { |p| list << Asciidoctor::ListItem.new(list, p) }

        doc.blocks << list
        # [unstyled]
        # * xref:posts/2026-03-19-exquis-setup.adoc[Exquis setup]
        # * xref:posts/2015-07-01-ruby-variable-initialisation.adoc[Ruby variable initialisation]
      end
    end
  end
end
