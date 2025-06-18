# frozen_string_literal: true

require_relative "lib/version"
require "debug"

Gem::Specification.new do |spec|
  spec.name = "rubobot"
  spec.version = Rubobot::VERSION
  spec.authors = ["Nicholas Barone"]
  spec.email = ["nicktbarone@gmail.com"]

  spec.summary = "Agentic Ruby code generation and automation using RubyLLM."
  spec.description = "This gem provides a command-line tool for generating code \
    using an AI programming agent written in Ruby. It leverages the RubyLLM library to \
    interact with AI models, allowing users to automate coding tasks and generate Ruby code \
    based on natural language prompts."

  spec.homepage = "https://github.com/rangerscience/rubobot"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = File.join(spec.homepage, "CHANGELOG.md")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|.ai)/}) }
  end
  spec.files += Dir.glob(".ai/instructions/**/*")

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "debug", "~> 1.1"
  spec.add_dependency "ruby_llm", "~> 1.3.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  # spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["rubygems_mfa_required"] = "true"
end
