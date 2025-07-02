require_relative '../agent'
require_relative '../tool'

module Agents
  class InfoAssembler < Agent
    description "An agent that gathers and organizes information needed for other agents to complete plan steps."
    param :plan_step, desc: "The plan step that needs information gathered"
    param :output_file, desc: "Name of the file to write the assembled information to"

    def tools
      [
        Tools::Files::List,
        Tools::Files::Read,
        Tools::Files::Find,
        # Tools::Git::Status,
        # Tools::Git::Log,
        # Tools::Git::Diff,
      ]
    end

    def info_file(name = "assembled_info.json")
      File.join(scratch_dir, 'scratch', name)
    end

    def execute(plan_step:, output_file:)
      response = @agent.ask(plan_step)
      FileUtils.mkdir_p(File.dirname(info_file(output_file)))
      File.write(info_file(output_file), response.content)
      return "Information for plan step has been assembled and written to #{output_file}"
    end
  end
end