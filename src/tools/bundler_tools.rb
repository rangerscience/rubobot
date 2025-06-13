# frozen_string_literal: true

require 'ruby_llm/tool'
require 'English'

module Tools
  module Bundler
    # Installs dependencies specified in Gemfile
    class Install < RubyLLM::Tool
      description 'Install the dependencies specified in your Gemfile'
      param :path, desc: 'Specify a different path than the current directory for the Gemfile', required: false
      param :without, desc: 'Exclude gems that are part of the specified named group', required: false
      param :jobs, desc: 'Install gems using parallel workers', required: false

      def execute(path: nil, without: nil, jobs: nil)
        cmd = 'bundle install'
        cmd += " --path=#{path}" if path && !path.empty?
        cmd += " --without=#{without}" if without && !without.empty?
        cmd += " --jobs=#{jobs}" if jobs && !jobs.empty?

        output = `#{cmd} 2>&1`

        if $CHILD_STATUS.success?
          "Bundle install succeeded"
        else
          { error: "Bundle install failed: #{output.strip}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end

    # Updates gems specified in the bundle
    class Update < RubyLLM::Tool
      description 'Update the gems specified (all gems if none specified)'
      param :gems, desc: 'Optional list of gems to update', required: false
      param :group, desc: 'Only update the gems in the specified group', required: false
      param :source, desc: 'The name of a source to update', required: false

      def execute(gems: nil, group: nil, source: nil)
        cmd = 'bundle update'

        if gems && !gems.empty?
          cmd += if gems.is_a?(Array)
                   " #{gems.join(' ')}"
                 else
                   " #{gems}"
                 end
        end

        cmd += " --group=#{group}" if group && !group.empty?
        cmd += " --source=#{source}" if source && !source.empty?

        output = `#{cmd} 2>&1`

        if $CHILD_STATUS.success?
          "Bundle update succeeded"
        else
          { error: "Bundle update failed: #{output.strip}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end

    # Adds a gem to the Gemfile and runs bundle install
    class Add < RubyLLM::Tool
      description 'Add the specified gem to the Gemfile and run bundle install'
      param :gem_name, desc: 'The name of the gem to add'
      param :version, desc: 'The version of the gem to add (e.g., \'~> 1.0.0\')', required: false
      param :group, desc: 'The group to add the gem to (e.g., \'development\')', required: false

      def execute(gem_name:, version: nil, group: nil)
        cmd = "bundle add #{gem_name}"
        cmd += " --version='#{version}'" if version && !version.empty?
        cmd += " --group=#{group}" if group && !group.empty?

        output = `#{cmd} 2>&1`

        if $CHILD_STATUS.success?
          "Bundle add succeeded"
        else
          { error: "Bundle add failed: #{output.strip}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end

    # Removes a gem from the Gemfile and runs bundle install
    class Remove < RubyLLM::Tool
      description 'Remove the specified gem from the Gemfile and run bundle install'
      param :gem_name, desc: 'The name of the gem to remove'

      def execute(gem_name:)
        cmd = "bundle remove #{gem_name}"

        output = `#{cmd} 2>&1`

        if $CHILD_STATUS.success?
          "Bundle remove succeeded"
        else
          { error: "Bundle remove failed: #{output.strip}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end

    # Lists all gems in the bundle
    class List < RubyLLM::Tool
      description 'List all gems in the bundle'
      param :name, desc: 'Filter for gems with the specified name', required: false

      def execute(name: nil)
        cmd = 'bundle list'
        cmd += " --name=#{name}" if name && !name.empty?

        output = `#{cmd} 2>&1`

        if $CHILD_STATUS.success?
          output.strip
        else
          { error: "Bundle list failed: #{output.strip}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end

    # Shows information for a specific gem in the bundle
    class Info < RubyLLM::Tool
      description 'Show information for the specified gem in the bundle'
      param :gem_name, desc: 'The name of the gem to get info for'

      def execute(gem_name:)
        cmd = "bundle info #{gem_name}"

        output = `#{cmd} 2>&1`

        if $CHILD_STATUS.success?
          output.strip
        else
          { error: "Bundle info failed: #{output.strip}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end

    # Shows all outdated gems in the bundle
    class Outdated < RubyLLM::Tool
      description 'Show all outdated gems in the bundle'
      param :filter, desc: 'Only list gems with names matching this filter', required: false

      def execute(filter: nil)
        cmd = 'bundle outdated'
        cmd += " #{filter}" if filter && !filter.empty?

        output = `#{cmd} 2>&1`

        if $CHILD_STATUS.success?
          output.strip.empty? ? 'No outdated gems found.' : output.strip
        else
          { error: "Bundle outdated failed: #{output.strip}" }
        end
      rescue StandardError => e
        { error: e.message }
      end
    end
  end
end
