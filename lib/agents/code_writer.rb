require_relative '../agent'
require_relative '../tool'

module Agents
  class CodeWriter < Agent
    description "An agent that writes code to accomplish a task"
    param :prompt, desc: "The task to write code for"
    param :info_file, desc: "A file containing the information to complete the task (required)"

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

    def execute(prompt:, info_file:)
      response = @agent.ask("""
      Your task is:
        #{prompt}

      Here is the information you have to start with:
      #{read_file(info_file)}
      """)
    rescue StandardError => e
      debugger
    end
  end
end