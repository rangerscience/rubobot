# frozen_string_literal: true

require 'English'
require_relative '../tool'

module Tools
  module Git
    class Commit < Tool
      description 'Create a git commit with the specified message. Optionally add specific files or add all changes.'
      param :message, desc: 'The commit message.'
      param :add_all, desc: 'Whether to add all changes before committing. Set to true or false.', required: false
      param :files, desc: 'List of specific files to add to the commit. Ignored if add_all is true.', required: false

      def execute(message:, add_all: false, files: nil)
        return { error: 'Not a git repository' } unless Dir.exist?('.git')

        if add_all
          system('git add -A')
          'Added all changes.'
        elsif files
          file_list = files.is_a?(Array) ? files.join(' ') : files
          system("git add #{file_list}")
          "Added: #{file_list}"
        else
          'No files added. Committing staged changes.'
        end

        run_command(`git commit -m "[AGENT] #{message}"`)
      end
    end

    class Status < Tool
      description 'Show the working tree status.'

      def execute
        return { error: 'Not a git repository' } unless Dir.exist?('.git')

        run_command('git status')
      end
    end

    class Diff < Tool
      description 'Show changes between commits, commit and working tree, etc.'
      param :path, desc: 'Optional path to specific file or directory to show diff for.', required: false
      param :staged, desc: 'Whether to show staged changes (--cached). Set to true or false.', required: false

      def execute(path: nil, staged: false)
        return { error: 'Not a git repository' } unless Dir.exist?('.git')

        cmd = 'git diff'
        cmd += ' --cached' if staged
        cmd += " #{path}" if path && !path.empty?

        run_command(cmd)
      end
    end

    class Log < Tool
      description 'Show commit logs.'
      param :number, desc: 'Number of commits to show. Default is 10.', required: false
      param :path, desc: 'Optional path to specific file or directory to show history for.', required: false
      param :format, desc: "Format of the log output. Options: 'oneline', 'short', 'medium', 'full', 'fuller'.",
                     required: false

      def execute(number: 10, path: nil, format: nil)
        return { error: 'Not a git repository' } unless Dir.exist?('.git')

        cmd = "git log -n #{number}"

        if format
          format = format.downcase
          valid_formats = %w[oneline short medium full fuller]
          cmd += format == 'oneline' ? ' --oneline' : " --format=#{format}" if valid_formats.include?(format)
        end

        cmd += " -- #{path}" if path && !path.empty?

        run_command(cmd)
      end
    end
  end
end
