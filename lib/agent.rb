# frozen_string_literal: true

require "fileutils"
require "ruby_llm"
require "time"
require "debug"

require_relative './tool'

class Agent < RubyLLM::Tool
  def initialize()
    @input_tokens = []
    @output_tokens = []
    @instructions = read_file(base_instructions_file)
    initialize_chat
  end

  def execute(...)
    execute(...)
  rescue StandardError => e
    { error: e.message }
  end

  def tools
    []
  end

  def base_instructions_file
    File.join(__dir__, "..", ".ai", *self.class.name.split("::"), "instructions.txt")
  end

  def read_file(path)
    File.exist?(path) ? File.read(path).strip : nil
  end

  def usage_percent(tokens, limit)
    (token_usage_last_minute(tokens) / limit.to_f * 100).to_i
  end

  def log_line response
    usage = "[#{usage_percent(@input_tokens, 20_000)}%]"
    sig = "[#{usage_percent(@input_tokens, 20_000)}%] #{}"
    msg = if response.role == :tool
      tool_call = @chat.messages[-2].tool_calls[response.tool_call_id]
      tool_call.name
    else
      response.content
    end
    puts "#{usage} #{self.class.name} > #{response.role} : #{msg}"
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
