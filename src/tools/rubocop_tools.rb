require "ruby_llm/tool"
require "json"

module Tools
  module Rubocop
    class Lint < RubyLLM::Tool
      description "Run RuboCop to lint your Ruby code and get a report of all offenses."
      param :path, desc: "Optional path to specific file or directory to lint. If not provided, all files will be checked.", required: false

      def execute(path: nil)
        command = "bundle exec rubocop"
        command += " #{path}" if path
        command += " --format json"

        output = `#{command} 2>&1`
        exit_status = $?.success?

        begin
          result = JSON.parse(output)
          format_lint_result(result)
        rescue JSON::ParserError
          exit_status ? output : { error: "RuboCop lint failed: #{output}" }
        rescue StandardError => e
          { error: e.message }
        end
      end

      private

      def format_lint_result(result)
        summary = result["summary"]
        files = result["files"]

        output = "RuboCop Inspection Results:\n"
        output += "#{summary['offense_count']} offense(s) detected in #{files.length} file(s)\n\n"

        files.each do |file|
          next if file["offenses"].empty?

          output += "File: #{file['path']}\n"
          file["offenses"].each do |offense|
            output += "  Line #{offense['location']['line']}: #{offense['message']} (#{offense['cop_name']})\n"
          end
          output += "\n"
        end

        output
      end
    end

    class Autocorrect < RubyLLM::Tool
      description "Run RuboCop autocorrect to automatically fix offenses in your Ruby code."
      param :path, desc: "Optional path to specific file or directory to autocorrect. If not provided, all files will be corrected.", required: false
      param :safe, desc: "Whether to use safe autocorrection (true) or unsafe autocorrection (false). Default is true.", required: false

      def execute(path: nil, safe: "true")
        flag = safe.to_s.downcase == "true" ? "-a" : "-A"
        command = "bundle exec rubocop #{flag}"
        command += " #{path}" if path

        output = `#{command} 2>&1`
        exit_status = $?.success?

        if exit_status
          "RuboCop autocorrection completed:\n#{output}"
        else
          { error: "RuboCop autocorrection failed: #{output}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end

    class ExplainOffense < RubyLLM::Tool
      description "Get an explanation for a specific RuboCop cop or offense."
      param :cop_name, desc: "The name of the RuboCop cop to explain (e.g., 'Style/StringLiterals')."

      def execute(cop_name:)
        command = "bundle exec rubocop --help #{cop_name}"
        output = `#{command} 2>&1`
        exit_status = $?.success?

        if exit_status
          return "No documentation found for #{cop_name}." if output.include?("no documentation")
          "Explanation for #{cop_name}:\n#{output}"
        else
          { error: "Failed to get explanation: #{output}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end
  end
end