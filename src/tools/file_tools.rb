require "ruby_llm/tool"

module Tools
  # Helper module to check for restricted files
  module FileRestrictions
    RESTRICTED_FILES = [".env", ".mise.toml"]

    def self.restricted?(path)
      filename = File.basename(path)
      RESTRICTED_FILES.include?(filename)
    end

    def self.check_restrictions(path)
      if restricted?(path)
        return { restricted: true,
                 message: "Access to #{path} is restricted for security reasons. This file contains sensitive configuration and cannot be accessed." }
      end

      { restricted: false }
    end
  end

  class ListFiles < RubyLLM::Tool
    description "List files and directories at a given path. If no path is provided, lists files in the current directory. Note: While you can see .env and .mise.toml files in listings, you cannot read or modify them."
    param :path, desc: "Optional relative path to list files from. Defaults to current directory if not provided."

    def execute(path: "")
      Dir.glob(File.join(path, "*"))
         .map { |filename| File.directory?(filename) ? "#{filename}/" : filename }
    rescue StandardError => e
      { error: e.message }
    end
  end

  class ReadFile < RubyLLM::Tool
    description "Read the contents of a given relative file path. Use this when you want to see what's inside a file. Do not use this with directory names. Note: Reading .env and .mise.toml files is restricted."
    param :path, desc: "The relative path of a file in the working directory."

    def execute(path:)
      check = FileRestrictions.check_restrictions(path)
      return check[:message] if check[:restricted]

      File.read(path)
    rescue StandardError => e
      { error: e.message }
    end
  end

  class WriteFile < RubyLLM::Tool
    description "Write content to a file at the specified path. If the file already exists, it will be overwritten. Note: Writing to .env and .mise.toml files is restricted."
    param :path, desc: "The relative path of the file to write."
    param :content, desc: "The content to write to the file."

    def execute(path:, content:)
      check = FileRestrictions.check_restrictions(path)
      return check[:message] if check[:restricted]

      puts "Writing to #{path}"

      # Create directory if it doesn't exist
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir) unless dir == "." || Dir.exist?(dir)

      # Write the content to the file
      File.write(path, content)

      "Successfully wrote #{content.bytesize} bytes to #{path}"
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
    param :path, desc: "The path to the file"
    param :old_str, desc: "Text to search for - must match exactly and must only have one match exactly"
    param :new_str, desc: "Text to replace old_str with"

    def execute(path:, old_str:, new_str:)
      check = FileRestrictions.check_restrictions(path)
      return check[:message] if check[:restricted]

      content = File.exist?(path) ? File.read(path) : ""
      File.write(path, content.sub(old_str, new_str))
    rescue StandardError => e
      { error: e.message }
    end
  end
end
