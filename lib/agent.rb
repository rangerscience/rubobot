# frozen_string_literal: true

require "fileutils"
require "ruby_llm"
require "time"
require "debug"

# Require all tool files
Dir[File.join(__dir__, "tools", "*.rb")].each { |file| require_relative file }

SUMMARY_PROMPT = "The conversation history is getting quite long. \
  Please provide a concise summary of all prior messages to minimize \
  token usage going forward. Focus only on the most important information \
  and context needed to continue the conversation effectively."

class Agent
  def initialize()
    @input_tokens = []
    @output_tokens = []
    @instructions = read_file(base_instructions_file)
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

  def base_instructions_file
    File.join(__dir__, "..", ".ai", *self.class.name.split("::"), "instructions.txt")
  end

  def read_file(path)
    File.exist?(path) ? File.read(path).strip : nil
  end

  def initialize_chat
    @chat = RubyLLM.chat
    @chat.with_tools(*tools)
    @chat.with_instructions(@instructions) if @instructions

    @chat.on_end_message do |response|
      now = Time.now
      # TODO: Feels a little odd that tool calls have nil token counts...
      @input_tokens << [now, response.input_tokens] unless response.input_tokens.nil?
      @output_tokens << [now, response.output_tokens] unless response.output_tokens.nil?
      log_line(response)
      delay(@input_tokens, 20_000)
      delay(@output_tokens, 3_000)
    end
  end

  def delay(tokens, limit)
    delayed = false
    while token_usage_last_minute(tokens) >= limit do
      delayed = true
      print "."
      sleep(1)
    end
    print "\n" if delayed
  end

  def execute(prompt)
    chat(prompt)
  end

  def chat(msg)
    delay(@input_tokens, 20_000 - msg.split.count)
    @chat.ask(msg)
  rescue RubyLLM::RateLimitError
    puts "Rate limit hit. Waiting..."
    sleep(70)
    retry
  end

  def token_usage_last_minute(records)
    cutoff = Time.now - 60
    records.select { |time, _| time > cutoff }.sum { |_, count| count }
  end
end

# Require all agent files
Dir[File.join(__dir__, "agents", "*.rb")].each { |file| require_relative file }
