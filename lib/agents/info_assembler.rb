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
        Tools::Git::Status,
        Tools::Git::Log,
        Tools::Git::Diff,
      ]
    end

    def info_file(name = "assembled_info.json")
      File.join(__dir__, 'scratch', name)
    end

    def analysis_prompt plan_step
      <<~PROMPT
        I need to gather information to help complete the following plan step:

        #{plan_step}

        Please analyze this plan step and determine:
        1. What specific information is needed to complete this step?
        2. What files, code, or documentation should be examined?
        3. What context from the project would be helpful?
        4. Are there any dependencies or prerequisites that should be checked?

        Use the available tools to gather all necessary information.
        Organize your findings in a clear, structured format that will help complete the task.
      PROMPT
    end

    def execute(plan_step:, output_file:)
      response = @chat.ask(analysis_prompt(plan_step))
      FileUtils.mkdir_p(File.dirname(info_file(output_file)))
      File.write(info_file(output_file), response.content)
      return "Information for plan step has been assembled and written to #{output_file}"
    end
  end
end