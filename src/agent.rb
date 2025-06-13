# frozen_string_literal: true

require 'debug'
require 'fileutils'
require 'logger'
require 'ruby_llm'

# Dynamically require all tool files
Dir[File.join(__dir__, 'tools', '*.rb')].sort.each do |file|
  require_relative file
end

class Agent
  def initialize(working_dir: './')
    @working_dir = working_dir
    FileUtils.mkdir_p(@working_dir)

    # Initialize chat with tools
    initialize_chat
  end

  def tools(base = Tools)
    base.constants.flat_map do |const|
      tool = base.const_get(const)
      if tool.is_a?(Class) && tool.ancestors.include?(RubyLLM::Tool)
        tool
      elsif tool.is_a?(Module)
        tools(tool)
      end
    end.compact
  end

  def instructions
    return @instructions if @instructions

    instructions_file = File.join(@working_dir, '.ai', 'instructions.txt')
    return nil unless File.exist?(instructions_file)

    @instructions = File.read(instructions_file).strip
  end

  def prompt
    return @prompt if @prompt

    prompt_file = File.join(@working_dir, '.ai', 'prompt.txt')
    return nil unless File.exist?(prompt_file)

    @prompt = File.read(prompt_file).strip
  end

  def initialize_chat
    @chat = RubyLLM.chat
    @chat.with_tools(*tools)
    @chat.with_instructions instructions unless instructions.nil?
  end

  def chat(msg)
    response = @chat.ask msg
    response.content
  rescue RubyLLM::RateLimitError
    puts 'Rate limit exceeded. Please wait before sending more requests.'
    sleep 70
    retry
  rescue RubyLLM::Error => e
    puts "Error: #{e.message}"
    nil
  end

  def run
    puts "Chat with the agent. Type 'exit' to ... well, exit"
    puts "Working in directory: #{@working_dir}"

    # Change to the working directory
    original_dir = Dir.pwd
    Dir.chdir(@working_dir)

    chat prompt unless prompt.nil?

    loop do
      print '> '
      user_input = $stdin.gets.chomp

      if user_input == 'exit'
        break
      elsif user_input == 'reset'
        puts 'Resetting context...'
        initialize_chat
      else
        chat user_input
      end
    end
  ensure
    # Change back to the original directory before exiting
    Dir.chdir(original_dir)
  end
end
