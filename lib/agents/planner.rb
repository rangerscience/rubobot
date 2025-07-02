require_relative '../agent'
require_relative '../tool'

module Agents
  class Planner < Agent
    description "An agent that turns a prompt into a plan and writes it to a file."
    param :prompt, desc: "The prompt to plan for"
    param :output_file, desc: "Name of the file to write the assembled information to"

    def tools
      [
        Tools::Files::List,
        Tools::Files::Read,
        Tools::Files::Find,
        Tools::UserInput::Request,
      ]
    end

    def plan_file(name = "plan.txt")
      File.join(scratch_dir, name)
    end

    def execute(prompt:, output_file:)
      response = @agent.ask(prompt)
      File.write(plan_file(output_file), response.content)
      "Plan written to file"
    rescue StandardError => e
      debugger
    end
  end
end