require "ruby_llm"
require "fileutils"
require "logger"
require "debug"

# Dynamically require all tool files
Dir[File.join(__dir__, "tools", "*.rb")].each do |file|
  require_relative file
end

class Agent
  def initialize(working_dir: "./")
    @working_dir = working_dir
    FileUtils.mkdir_p(@working_dir) unless Dir.exist?(@working_dir)

    # Initialize chat with tools
    initialize_chat
  end

  def initialize_chat
    @chat = RubyLLM.chat

    # Find all tool classes in the Tools namespace
    tools = []

    # Add regular tools
    Tools.constants.each do |const|
      tool = Tools.const_get(const)
      if tool.is_a?(Class) && tool.ancestors.include?(RubyLLM::Tool)
        tools << tool
      elsif tool.is_a?(Module)
        # Handle nested modules like Tools::Git
        tool.constants.each do |nested_const|
          nested_tool = tool.const_get(nested_const)
          tools << nested_tool if nested_tool.is_a?(Class) && nested_tool.ancestors.include?(RubyLLM::Tool)
        end
      end
    end

    # Load all tools
    @chat.with_tools(*tools)

    # Read baseline prompt from file
    return unless File.exist?(File.join(@working_dir, ".ai", "base.txt"))

    base = File.read(File.join(@working_dir, ".ai", "base.txt"))
    @chat.with_instructions base unless base.empty?
  end

  def run
    puts "Chat with the agent. Type 'exit' to ... well, exit"
    puts "Working in directory: #{@working_dir}"

    # Change to the working directory
    original_dir = Dir.pwd
    Dir.chdir(@working_dir)

    if File.exist? File.join(@working_dir, ".ai", "prompt.txt")
      prompt = File.read File.join(@working_dir, ".ai", "prompt.txt")
      unless prompt.empty?
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

        if user_input == "exit"
          break
        elsif user_input == "reset"
          puts "Resetting context..."
          initialize_chat
        else
          response = @chat.ask user_input
          puts response.content
        end
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
