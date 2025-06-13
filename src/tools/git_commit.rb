require "ruby_llm/tool"

module Tools
  class GitCommit < RubyLLM::Tool
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
end