# frozen_string_literal: true

require 'ruby_llm/tool'

module Tools
  RESTRICTED_FILES = ['.env', '.mise.toml'].freeze
  RESTRICTED_MESSAGE = 'Access to this file is restricted for security reasons. This file contains sensitive configuration and cannot be accessed.'

  def self.unless_restricted(path)
    if RESTRICTED_FILES.include?(File.basename(path))
      RESTRICTED_MESSAGE
    else
      yield
    end
  end

  class ListFiles < RubyLLM::Tool
    description 'List files and directories. Restricted files are visible but cannot be accessed.'
    param :path, desc: 'Path to list files from (optional, defaults to current directory)'

    def execute(path: '')
      Dir.glob(File.join(path, '*'))
         .map { |filename| File.directory?(filename) ? "#{filename}/" : filename }
    rescue StandardError => e
      { error: e.message }
    end
  end

  class ReadFile < RubyLLM::Tool
    description "Show file contents. Cannot read restricted files or directories."
    param :path, desc: 'File path to read'

    def execute(path:)
      unless_restricted(path) do
        File.read(path)
      end
    rescue StandardError => e
      { error: e.message }
    end
  end

  class WriteFile < RubyLLM::Tool
    description 'Write content to a file at the specified path. If the file already exists, it will be overwritten. Note: Writing to .env and .mise.toml files is restricted.'
    param :path, desc: 'The relative path of the file to write.'
    param :content, desc: 'The content to write to the file.'

    def execute(path:, content:)
      unless_restricted(path) do
        dir = File.dirname(path)
        FileUtils.mkdir_p(dir) unless dir == '.' || Dir.exist?(dir)
        File.write(path, content)
      end
    rescue StandardError => e
      { error: e.message }
    end
  end

  class EditFile < RubyLLM::Tool
    description <<~DESCRIPTION
      Make edits to a text file.

      Replaces 'old_str' with 'new_str' in the given file.
      'old_str' and 'new_str' MUST be different from each other.

      If the file specified with path doesn't exist, it will be created.

      Note: Editing .env and .mise.toml files is restricted.
    DESCRIPTION
    param :path, desc: 'The path to the file'
    param :old_str, desc: 'Text to search for - must match exactly and must only have one match exactly'
    param :new_str, desc: 'Text to replace old_str with'

    def execute(path:, old_str:, new_str:)
      unless_restricted(path) do
        content = File.exist?(path) ? File.read(path) : ''
        File.write(path, content.sub(old_str, new_str))
      end
    rescue StandardError => e
      { error: e.message }
    end
  end
end
