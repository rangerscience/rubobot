require "ruby_llm/tool"

module Tools
  module Git
    class Commit < RubyLLM::Tool
      description "Create a git commit with the specified message. Optionally add specific files or add all changes."
      param :message, desc: "The commit message."
      param :add_all, desc: "Whether to add all changes before committing. Set to true or false.", required: false
      param :files, desc: "List of specific files to add to the commit. Ignored if add_all is true.", required: false

      def execute(message:, add_all: false, files: nil)
        # Validate git repository
        unless Dir.exist?(".git")
          return { error: "Not a git repository. Initialize a git repository first with 'git init'." }
        end

        # Add changes
        if add_all
          system("git add -A")
          add_result = "Added all changes."
        elsif files && !files.empty?
          if files.is_a?(Array)
            file_list = files.join(" ")
            system("git add #{file_list}")
            add_result = "Added files: #{file_list}"
          else
            system("git add #{files}")
            add_result = "Added file: #{files}"
          end
        else
          # If neither add_all nor files are specified, just commit what's already staged
          add_result = "No files were added. Committing already staged changes."
        end

        # Create the commit
        commit_output = `git commit -m "#{message}" 2>&1`
        commit_status = $?.success?

        if commit_status
          "#{add_result}\nCommit successful: #{commit_output.strip}"
        else
          { error: "Commit failed: #{commit_output.strip}" }
        end
      rescue => e
        { error: e.message }
      end
    end

    class Status < RubyLLM::Tool
      description "Show the working tree status. Displays paths that have differences between the index file and the current HEAD commit, paths that have differences between the working tree and the index file, and paths in the working tree that are not tracked by Git."
      
      def execute
        # Validate git repository
        unless Dir.exist?(".git")
          return { error: "Not a git repository. Initialize a git repository first with 'git init'." }
        end

        status_output = `git status 2>&1`
        status_status = $?.success?

        if status_status
          status_output.strip
        else
          { error: "Git status failed: #{status_output.strip}" }
        end
      rescue => e
        { error: e.message }
      end
    end

    class Diff < RubyLLM::Tool
      description "Show changes between commits, commit and working tree, etc."
      param :path, desc: "Optional path to specific file or directory to show diff for.", required: false
      param :staged, desc: "Whether to show staged changes (--cached). Set to true or false.", required: false
      
      def execute(path: nil, staged: false)
        # Validate git repository
        unless Dir.exist?(".git")
          return { error: "Not a git repository. Initialize a git repository first with 'git init'." }
        end

        cmd = "git diff"
        cmd += " --cached" if staged
        cmd += " #{path}" if path && !path.empty?
        cmd += " 2>&1"

        diff_output = `#{cmd}`
        diff_status = $?.success?

        if diff_status
          diff_output.empty? ? "No changes found." : diff_output.strip
        else
          { error: "Git diff failed: #{diff_output.strip}" }
        end
      rescue => e
        { error: e.message }
      end
    end

    class Log < RubyLLM::Tool
      description "Show commit logs."
      param :number, desc: "Number of commits to show. Default is 10.", required: false
      param :path, desc: "Optional path to specific file or directory to show history for.", required: false
      param :format, desc: "Format of the log output. Options: 'oneline', 'short', 'medium', 'full', 'fuller'.", required: false
      
      def execute(number: 10, path: nil, format: nil)
        # Validate git repository
        unless Dir.exist?(".git")
          return { error: "Not a git repository. Initialize a git repository first with 'git init'." }
        end

        cmd = "git log -n #{number}"
        
        if format
          case format.downcase
          when 'oneline'
            cmd += " --oneline"
          when 'short', 'medium', 'full', 'fuller'
            cmd += " --format=#{format.downcase}"
          end
        end
        
        cmd += " -- #{path}" if path && !path.empty?
        cmd += " 2>&1"

        log_output = `#{cmd}`
        log_status = $?.success?

        if log_status
          log_output.empty? ? "No commit history found." : log_output.strip
        else
          { error: "Git log failed: #{log_output.strip}" }
        end
      rescue => e
        { error: e.message }
      end
    end
  end
end