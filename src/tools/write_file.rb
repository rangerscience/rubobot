require "ruby_llm/tool"

module Tools
  class WriteFile < RubyLLM::Tool
    description "Write content to a file at the specified path. If the file already exists, it will be overwritten."
    param :path, desc: "The relative path of the file to write."
    param :content, desc: "The content to write to the file."

    def execute(path:, content:)
      puts "Writing to #{path}"
      
      # Create directory if it doesn't exist
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir) unless dir == "." || Dir.exist?(dir)
      
      # Write the content to the file
      File.write(path, content)
      
      "Successfully wrote #{content.bytesize} bytes to #{path}"
    rescue => e
      { error: e.message }
    end
  end
end