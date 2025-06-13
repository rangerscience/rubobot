require "ruby_llm"
require "fileutils"
require "logger"
require 'debug'

require_relative "tools/read_file"
require_relative "tools/list_files"
require_relative "tools/edit_file"
require_relative "tools/run_shell_command"
require_relative "tools/write_file"
require_relative "tools/git"
require_relative "tools/reset_context"

class Agent
  def initialize(working_dir: "./")
    @working_dir = working_dir
    FileUtils.mkdir_p(@working_dir) unless Dir.exist?(@working_dir)
    
    # Initialize chat with tools
    initialize_chat
  end
  
  def initialize_chat
    @chat = RubyLLM.chat
    @chat.with_tools(Tools::ReadFile, Tools::ListFiles, Tools::EditFile, 
                    Tools::RunShellCommand, Tools::WriteFile, 
                    Tools::Git::Commit, Tools::Git::Status, Tools::Git::Diff, Tools::Git::Log,
                    Tools::ResetContext)
    
    # Read baseline prompt from file
    if File.exist?(File.join(@working_dir, ".ai", "base.txt"))
      base = File.read(File.join(@working_dir, ".ai", "base.txt"))
      @chat.with_instructions base if !base.empty?
    end
  end
  
  def reset_context
    # Create a new chat instance with the same configuration
    initialize_chat
    puts "Chat context has been reset."
  end

  def run
    puts "Chat with the agent. Type 'exit' to ... well, exit"
    puts "Working in directory: #{@working_dir}"
    
    # Change to the working directory
    original_dir = Dir.pwd
    Dir.chdir(@working_dir)

    if File.exist? File.join(@working_dir, ".ai", "prompt.txt")
      prompt = File.read File.join(@working_dir, ".ai", "prompt.txt")
      if !prompt.empty?
        begin
          response = @chat.ask prompt
          puts response.content
        rescue RubyLLM::RateLimitError => e
          puts "Rate limit exceeded. Please wait before sending more requests."
          sleep 70
          retry
        end
      end
    end
    
    begin
      loop do
        print "> "
        user_input = $stdin.gets.chomp
        break if user_input == "exit"
        
        response = @chat.ask user_input
        puts response.content
      rescue RubyLLM::RateLimitError => e
        puts "Rate limit exceeded. Please wait before sending more requests."
        sleep 70
        retry
      end
    rescue RubyLLM::Error => e
      debugger
    ensure
      # Change back to the original directory before exiting
      Dir.chdir(original_dir)
    end
  end
end