# frozen_string_literal: true

require 'asciidoctor'
autoload :FileUtils, 'fileutils'

MASTER_FILENAME = 'home.adoc'
BUILD_DIR = 'build'

task default: [:clean] do
  Asciidoctor.convert_file MASTER_FILENAME,
                           safe: :unsafe,
                           to_dir: BUILD_DIR,
                           mkdirs: true
end

task :clean do
  FileUtils.remove_entry_secure BUILD_DIR if File.exist? BUILD_DIR
end
