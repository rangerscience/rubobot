# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../tool"

module Tools
  module UserInput
    class Request < Tool
      description "Request input from the user"
      param :prompt, desc: "The prompt to show to the user"

      def exec(prompt:)
        puts prompt
        print "> "
        $stdin.gets.chomp
      end
    end
  end
end
