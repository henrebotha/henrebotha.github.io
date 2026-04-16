require 'asciidoctor/extensions'

def find_posts
  Dir.glob('src/posts/*.adoc')
    .map { |p| p.gsub(/$/, '[' + File.open(p, &:readline).gsub(/^= /, '').strip + ']') }
    .map { |p| p.gsub(/^src\//, '') }
    .map { |p| 'xref:' + p }
end

Asciidoctor::Extensions.register do
  tree_processor do
    process do |doc|
      if doc.attr? 'generate-index'
        posts = find_posts()

        list = Asciidoctor::List.new(doc, :ulist, attributes: { 'role' => 'unstyled' })
        posts.each { |p| list << Asciidoctor::ListItem.new(list, p) }

        doc.blocks << list
        # [unstyled]
        # * xref:posts/2026-03-19-exquis-setup.adoc[Exquis setup]
        # * xref:posts/2015-07-01-ruby-variable-initialisation.adoc[Ruby variable initialisation]
      end
    end
  end
end
