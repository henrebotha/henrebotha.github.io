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

  {
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
  # TODO: Shouldn't this be a block macro, rather? Then we can position it
  # arbitrarily. And possibly even (if we're very lucky with how Asciidoctor
  # works) avoid having to parse file frontmatter ourselves.
  tree_processor do
    process do |doc|
      singleton_class.include Asciidoctor::Logging

      if doc.attr? 'generate-index'
        logger.info "Generating index for #{doc}"
        posts = parse_posts()

        post_list = Asciidoctor::List.new(doc, :ulist, attributes: { 'role' => 'post-list tnum' })
        post_list.style = 'unstyled'
        posts.reverse.map.with_index do |post, index|
          post[:litem] = Asciidoctor::ListItem.new(post_list, make_xref(post, index == 0))
          post
        end.reverse.each do |post|
          tag_list = Asciidoctor::List.new(post_list, :ulist, attributes: { 'role' => 'tags', 'options' => { 'nopara' => true, 'nodiv' => true } })
          tag_list.style = 'inline'
          post[:attributes][:tags].each do |tag|
            tag_list << Asciidoctor::ListItem.new(tag_list, tag)
          end
          post[:litem] << tag_list

          post_list << post[:litem]
        end

        doc << post_list
      end
    end
  end
end
