# frozen_string_literal: true

require 'fileutils'
require 'ruby_llm'
require 'time'
require 'debug'

# Require all tool files
Dir[File.join(__dir__, 'tools', '*.rb')].sort.each { |file| require_relative file }

class Agent
  def initialize(working_dir: './')
    @working_dir = working_dir
    FileUtils.mkdir_p(@working_dir)
    @input_tokens = []
    @output_tokens = []
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
    @instructions ||= read_file(File.join(@working_dir, '.ai', 'instructions.txt')) ||
                      read_file(File.join('.ai', 'instructions.txt'))
  end

  def prompt
    @prompt ||= read_file(File.join(@working_dir, '.ai', 'prompt.txt'))
  end

  def read_file(path)
    File.exist?(path) ? File.read(path).strip : nil
  end

  def initialize_chat
    @chat = RubyLLM.chat
    @chat.with_tools(*tools)
    @chat.with_instructions(instructions) if instructions

    @chat.on_end_message do |response|
      now = Time.now
      # TODO: Feels a little odd that tool calls have nil token counts...
      @input_tokens << [now, response.input_tokens] unless response.input_tokens.nil?
      @output_tokens << [now, response.output_tokens] unless response.output_tokens.nil?
      delay(@input_tokens, 20_000)
      delay(@output_tokens, 3_000)
    end
  end

  def delay(tokens, limit)
    puts '...'
    loop do
      return if token_usage_last_minute(tokens) < limit

      print '.'
      sleep(1)
    end
  end

  def estimate_token_count(text)
    # Simple estimation: ~4 characters per token on average
    # This is a rough approximation; more accurate counting would require a tokenizer
    text.length / 4
  end

  def chat(msg)
    # Check if the input token count exceeds 10,000
    estimated_tokens = estimate_token_count(msg)
    if estimated_tokens > 10_000
      puts "Message is very large (estimated #{estimated_tokens} tokens). Requesting a summary of prior context..."
      
      # Ask the agent to summarize prior messages
      summary_prompt = "The conversation history is getting quite long. Please provide a concise summary of all prior messages to minimize token usage going forward. Focus only on the most important information and context needed to continue the conversation effectively."
      
      # Send the summary request to the agent
      @chat.ask(summary_prompt)
      
      # After getting the summary, continue with the original message
      puts "Continuing with your original message..."
    end
    
    delay(@input_tokens, 20_000 - msg.split.count)
    @chat.ask(msg)
  rescue RubyLLM::RateLimitError
    puts 'Rate limit hit. Waiting...'
    sleep(70)
    retry
  rescue RubyLLM::Error => e
    File.write(File.join(@working_dir, '.ai', 'prompt.txt'), msg)
    puts "Error: #{e.message}"
    debugger
  rescue StandardError => e
    File.write(File.join(@working_dir, '.ai', 'prompt.txt'), msg)
    puts "Error: #{e.message}"
  end

  def token_usage_last_minute(records)
    cutoff = Time.now - 60
    records.select { |time, _| time > cutoff }.sum { |_, count| count }
  end

  def display_usage
    input = token_usage_last_minute(@input_tokens)
    output = token_usage_last_minute(@output_tokens)
    puts "Tokens (last 60s): In: #{input}, Out: #{output}, Total: #{input + output}"
  end

  def run
    puts "Chat with the agent. Type 'exit' to exit"
    puts "Working in: #{@working_dir}"

    orig_dir = Dir.pwd
    Dir.chdir(@working_dir)

    chat(prompt) if prompt

    loop do
      print '> '
      input = $stdin.gets.chomp

      case input
      when 'exit' then break
      when 'reset' then initialize_chat
      when 'usage' then display_usage
      else chat(input)
      end
    end
  ensure
    Dir.chdir(orig_dir)
  end
end
