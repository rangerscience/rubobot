# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../tool"
require "find"

module Tools
  module Files
    RESTRICTED = [".env", ".mise.toml"].freeze
    R_MSG = "Access restricted for security reasons."

    def self.safe(path)
      if RESTRICTED.include?(File.basename(path))
        R_MSG
      else
        yield
      end
    end

    class List < Tool
      description "List files/dirs"
      param :path, desc: "Path to list (default: current dir)"

      def execute(path: "")
        Dir.glob(File.join(path, "*"))
           .map { |f| File.directory?(f) ? "#{f}/" : f }
      end
    end

    class Read < Tool
      description "Show file contents"
      param :path, desc: "File to read"

      def execute(path:)
        Tools::Files.safe(path) { File.read(path) }
      end
    end

    class Write < Tool
      description "Write to file. Overwrites if exists"
      param :path, desc: "File path"
      param :content, desc: "Content to write"

      def execute(path:, content:)
        Tools::Files.safe(path) do
          dir = File.dirname(path)
          FileUtils.mkdir_p(dir) unless dir == "." || Dir.exist?(dir)
          File.write(path, content)
        end
      end
    end

    class Edit < Tool
      description "Edit text file by replacing old_str with new_str"
      param :path, desc: "File path"
      param :old_str, desc: "Text to replace"
      param :new_str, desc: "Replacement text"

      def execute(path:, old_str:, new_str:)
        Tools::Files.safe(path) do
          content = File.exist?(path) ? File.read(path) : ""
          File.write(path, content.sub(old_str, new_str))
        end
      end
    end

    class Find < Tool
      description "Find files matching a pattern"
      param :path, desc: "Base directory to search from"
      param :pattern, desc: 'Glob pattern to match files (e.g., "**/*.rb")'

      def execute(pattern:, path: ".")
        Dir.glob(File.join(path, pattern))
      end
    end
  end
end
