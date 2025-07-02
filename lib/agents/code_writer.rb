require_relative '../agent'
require_relative '../tool'

module Agents
  class CodeWriter < Agent
    description "An agent that writes code to accomplish a task"
    param :prompt, desc: "The task to write code for"

    def tools
      [
        Tools::Files::Find,
        Tools::Files::List,
        Tools::Files::Read,
        Tools::Files::Write,
        Tools::Files::Edit,
        Tools::Files::Append,
      ]
    end

    def execute(prompt:, output_file:)
      response = @chat.ask(prompt)
    rescue StandardError => e
      debugger
    end
  end
end