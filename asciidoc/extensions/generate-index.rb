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
      name = name.gsub(/(^:|:$)/, '')
      if name == 'tags'
        value = value.split(/, ?/)
      elsif name == 'date'
        value = value.match(/^\d{4}-\d{2}-\d{2}/)[0]
      end
      attributes[name.to_sym] = value
    end
  end

  return {
    title: title,
    path: file_path.gsub(/$/, '[' + title + ']').gsub(/^src\//, ''),
    attributes: attributes
  }
end

def parse_posts
  Dir.glob('src/posts/*.adoc')
    .map { |p| parse_post(p) }
end

def make_xref(post, is_last)
  post[:attributes][:date] + (is_last ? ' (latest): ' : ': ') + 'xref:' + post[:path]
end

Asciidoctor::Extensions.register do
  tree_processor do
    process do |doc|
      singleton_class.include Asciidoctor::Logging

      if doc.attr? 'generate-index'
        logger.info "Generating index for #{doc}"
        posts = parse_posts()

        list = Asciidoctor::List.new(doc, :ulist, attributes: { 'role' => 'tnum' })
        list.style = 'unstyled'
        posts.reverse.map.with_index do |post, index|
          post[:litem] = Asciidoctor::ListItem.new(list, make_xref(post, index == 0))
          post
        end.reverse.each do |post|
          taglist = Asciidoctor::List.new(list, :ulist, attributes: { 'role' => 'tags' })
          taglist.style = 'inline'
          post[:attributes][:tags].each do |tag|
            taglist << Asciidoctor::ListItem.new(taglist, tag)
          end
          post[:litem] << taglist

          list << post[:litem]
        end

        doc.blocks << list
      end
    end
  end
end
