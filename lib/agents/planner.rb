require_relative '../agent'
require_relative '../tool'

module Agents
  class Planner < Agent
    description "An agent that turns a prompt into a plan and writes it to a file."
    param :prompt, desc: "The prompt to plan for"
    param :plan_file_name, desc: "Name of the file to write the plan to"

    def tools
      [
        Tools::Files::List,
        Tools::Files::Read,
        Tools::Files::Find,
        Tools::UserInput::Request,
      ]
    end

    def plan_file(name = "plan.txt")
      File.join(__dir__, 'scratch', name)
    end

    def execute(prompt, plan_file_name)
      response = @chat.ask(prompt)
      File.write(plan_file(plan_file_name), response.content)
      "Plan written to file"
    end
  end
end