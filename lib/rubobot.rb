require_relative './agent'
require_relative './tool'

module Rubobot
  class Rubobot < Agent
    def tools
      [
        Tools::UserInput::Request,
        Agents::Planner,
        Agents::InfoAssembler,
      ]
    end

    def display_usage
      input = token_usage_last_minute(@input_tokens)
      output = token_usage_last_minute(@output_tokens)
      puts "Tokens (last 60s): In: #{input}, Out: #{output}, Total: #{input + output}"
    end

    def run
      loop do
        print "> "
        input = $stdin.gets.chomp

        case input
        when "exit" then break
        when "reset" then initialize_chat
        when "usage" then display_usage
        else chat(input)
        end
      end
    end
  end
end
