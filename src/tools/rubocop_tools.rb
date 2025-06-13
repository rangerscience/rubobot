# frozen_string_literal: true

require 'English'
require_relative '../tool'
require 'json'

module Tools
  module Rubocop
    class Lint < Tool
      description 'Run RuboCop to lint your Ruby code and get a report of all offenses.'
      param :path,
            desc: 'Optional path to specific file or directory to lint. If not provided, all files will be checked.', required: false

      def execute(path: nil)
        output = `bundle exec rubocop #{path} --format json 2>&1`.strip

        begin
          result = JSON.parse(output)
          summary = result['summary']
          files = result['files']

          text = "RuboCop: #{summary['offense_count']} offense(s) in #{files.length} file(s)\n\n"

          files.each do |file|
            next if file['offenses'].empty?

            text += "File: #{file['path']}\n"
            file['offenses'].each do |offense|
              loc = offense['location']
              text += "  Line #{loc['line']}: #{offense['message']} (#{offense['cop_name']})\n"
            end
            text += "\n"
          end

          text
        rescue JSON::ParserError
          $CHILD_STATUS.success? ? output : { error: "RuboCop lint failed: #{output}" }
        end
      end
    end

    class Autocorrect < Tool
      description 'Run RuboCop autocorrect to automatically fix offenses in your Ruby code.'
      param :path,
            desc: 'Optional path to specific file or directory to autocorrect. If not provided, all files will be corrected.', required: false
      param :safe,
            desc: 'Whether to use safe autocorrection (true) or unsafe autocorrection (false). Default is true.', required: false

      def execute(path: nil, safe: 'true')
        flag = safe.to_s.downcase == 'true' ? '-a' : '-A'
        output = `bundle exec rubocop #{flag} #{path} 2>&1`.strip
        $CHILD_STATUS.success? ? "RuboCop autocorrection completed:\n#{output}" : { error: "Failed: #{output}" }
      end
    end

    class ExplainOffense < Tool
      description 'Get an explanation for a specific RuboCop cop or offense.'
      param :cop_name, desc: "The name of the RuboCop cop to explain (e.g., 'Style/StringLiterals')."

      def execute(cop_name:)
        output = `bundle exec rubocop --help #{cop_name} 2>&1`
        return { error: "Failed: #{output}" } unless $CHILD_STATUS.success?

        output.include?('no documentation') ? "No docs for #{cop_name}" : "#{cop_name}:\n#{output}"
      end
    end
  end
end
