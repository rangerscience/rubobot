# frozen_string_literal: true

class Tool < RubyLLM::Tool
  def execute(...)
    exec(...)
  rescue StandardError => e
    { error: e.message }
  end

  def run_command(command, success_message: nil)
    output = `#{command} 2>&1`
    if $CHILD_STATUS.success?
      { command: command, result: success_message || output.strip }
    else
      { command: command, error: "Command failed: #{output.strip}" }
    end
  end

  def self.tools(base = Tools)
    base.constants.flat_map do |const|
      tool = base.const_get(const)
      if tool.is_a?(Class) && tool.ancestors.include?(RubyLLM::Tool)
        tool
      elsif tool.is_a?(Module)
        tools(tool)
      end
    end.compact
  end
end

# Require all tool files
Dir[File.join(__dir__, "tools", "*.rb")].each { |file| require_relative file }

