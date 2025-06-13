require "json"

module Tools
  class RubocopTools
    def self.register(registry)
      registry.register("tools--rubocop--lint", method(:lint))
      registry.register("tools--rubocop--autocorrect", method(:autocorrect))
      registry.register("tools--rubocop--explain_offense", method(:explain_offense))
    end

    def self.lint(path: nil)
      command = "bundle exec rubocop"
      command += " #{path}" if path
      command += " --format json"

      output = `#{command}`
      begin
        result = JSON.parse(output)
        format_lint_result(result)
      rescue JSON::ParserError
        output
      end
    end

    def self.autocorrect(path: nil, safe: "true")
      flag = safe.to_s.downcase == "true" ? "-a" : "-A"
      command = "bundle exec rubocop #{flag}"
      command += " #{path}" if path

      output = `#{command}`
      "Rubocop autocorrection completed:\n#{output}"
    end

    def self.explain_offense(cop_name:)
      command = "bundle exec rubocop --help #{cop_name}"
      output = `#{command}`

      return "No documentation found for #{cop_name}." if output.include?("no documentation")

      "Explanation for #{cop_name}:\n#{output}"
    end

    def self.format_lint_result(result)
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
end
