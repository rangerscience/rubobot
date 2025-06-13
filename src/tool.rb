# frozen_string_literal: true

class Tool < RubyLLM::Tool
  def execute(...)
    execute(...)
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
end
