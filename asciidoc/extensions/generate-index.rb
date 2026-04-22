require 'asciidoctor/extensions'

def parse_post(file_path)
  head = File.readlines(file_path, chomp: true)
    .take_while { |line| line != '' }

  title, lines = head.slice_after(/^\= .+$/).to_a
  title = title[0].gsub(/^\= /, '')

  attributes = {}

  lines.each do |line|
    if line.start_with?(/:[^:]+:/)
      name, value = line.split(' ', 2)
      attributes[name.gsub(/(^:|:$)/, '').to_sym] = value
    end
  end

  return {
    title: title,
    path: file_path.gsub(/$/, '[' + title + ']').gsub(/^src\//, ''),
    attributes: attributes
  }
end

def find_posts
  Dir.glob('src/posts/*.adoc')
    .reverse
    .map.with_index do |p, i|
      parsed = parse_post(p)
      title = parsed[:title]
      date = parsed[:attributes][:date].match(/^\d{4}-\d{2}-\d{2}/)[0]
      path = parsed[:path]
      date + (i == 0 ? ' (latest): ' : ': ') + 'xref:' + path
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
