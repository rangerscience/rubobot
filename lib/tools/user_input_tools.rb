# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../tool"

module Tools
  module UserInput
    class Request < Tool
      description "Request input from the user"
      param :prompt, desc: "The prompt to show to the user"
      param :default, desc: "Optional default value to suggest"

      def exec(prompt:, default: nil)
        print "#{prompt} "
        print "[#{default}] " if default
        input = gets.chomp
        input.empty? && default ? default : input
      end
    end
  end
end
