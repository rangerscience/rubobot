# frozen_string_literal: true

require_relative '../tool'

module Tools
  module Bundler
    # Base class for all Bundler commands
    class BundlerTool < Tool
      def run_bundle_command(cmd, args = {})
        full_cmd = build_command(cmd, args)
        output = `#{full_cmd} 2>&1`

        if $CHILD_STATUS.success?
          output.strip.empty? ? "Bundle #{cmd} succeeded" : output.strip
        else
          { error: "Bundle #{cmd} failed: #{output.strip}" }
        end
      end

      private

      def build_command(cmd, args)
        result = "bundle #{cmd}"
        
        args.each do |key, value|
          next if value.nil? || (value.respond_to?(:empty?) && value.empty?)
          
          if key == :gems && cmd == 'update'
            result += value.is_a?(Array) ? " #{value.join(' ')}" : " #{value}"
          elsif key == :filter && cmd == 'outdated'
            result += " #{value}"
          elsif key == :path && cmd == 'install'
            result += " --path=#{value}"
          elsif key == :version && cmd == 'add'
            result += " --version='#{value}'"
          else
            result += " --#{key}=#{value}"
          end
        end
        
        result
      end
    end

    # Installs dependencies specified in Gemfile
    class Install < BundlerTool
      description 'Install the dependencies specified in your Gemfile'
      param :path, desc: 'Specify a different path than the current directory for the Gemfile', required: false
      param :without, desc: 'Exclude gems that are part of the specified named group', required: false
      param :jobs, desc: 'Install gems using parallel workers', required: false

      def execute(path: nil, without: nil, jobs: nil)
        run_bundle_command('install', { path: path, without: without, jobs: jobs })
      end
    end

    # Updates gems specified in the bundle
    class Update < BundlerTool
      description 'Update the gems specified (all gems if none specified)'
      param :gems, desc: 'Optional list of gems to update', required: false
      param :group, desc: 'Only update the gems in the specified group', required: false
      param :source, desc: 'The name of a source to update', required: false

      def execute(gems: nil, group: nil, source: nil)
        run_bundle_command('update', { gems: gems, group: group, source: source })
      end
    end

    # Adds a gem to the Gemfile and runs bundle install
    class Add < BundlerTool
      description 'Add the specified gem to the Gemfile and run bundle install'
      param :gem_name, desc: 'The name of the gem to add'
      param :version, desc: 'The version of the gem to add (e.g., \'~> 1.0.0\')', required: false
      param :group, desc: 'The group to add the gem to (e.g., \'development\')', required: false

      def execute(gem_name:, version: nil, group: nil)
        run_bundle_command("add #{gem_name}", { version: version, group: group })
      end
    end

    # Removes a gem from the Gemfile and runs bundle install
    class Remove < BundlerTool
      description 'Remove the specified gem from the Gemfile and run bundle install'
      param :gem_name, desc: 'The name of the gem to remove'

      def execute(gem_name:)
        run_bundle_command("remove #{gem_name}")
      end
    end

    # Lists all gems in the bundle
    class List < BundlerTool
      description 'List all gems in the bundle'
      param :name, desc: 'Filter for gems with the specified name', required: false

      def execute(name: nil)
        run_bundle_command('list', { name: name })
      end
    end

    # Shows information for a specific gem in the bundle
    class Info < BundlerTool
      description 'Show information for the specified gem in the bundle'
      param :gem_name, desc: 'The name of the gem to get info for'

      def execute(gem_name:)
        run_bundle_command("info #{gem_name}")
      end
    end

    # Shows all outdated gems in the bundle
    class Outdated < BundlerTool
      description 'Show all outdated gems in the bundle'
      param :filter, desc: 'Only list gems with names matching this filter', required: false

      def execute(filter: nil)
        run_bundle_command('outdated', { filter: filter })
      end
    end
  end
end