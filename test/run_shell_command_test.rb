# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../src/tools/run_shell_command'
require 'stringio'

class TestRunShellCommand < Minitest::Test
  def setup
    @tool = Tools::RunShellCommand.new
    @original_stdout = $stdout
    $stdout = StringIO.new
  end

  def teardown
    $stdout = @original_stdout
  end

  def test_execute_command_when_approved
    @tool.stub :gets, "y\n" do
      result = @tool.execute(command: 'echo test')
      assert_equal "test\n", result
    end
  end

  def test_reject_command_execution
    @tool.stub :gets, "n\n" do
      result = @tool.execute(command: 'echo test')
      assert_equal({ error: 'User declined to execute the command' }, result)
    end
  end

  def test_command_failure
    @tool.stub :gets, "y\n" do
      result = @tool.execute(command: 'nosuchcommand')
      assert_equal({ error: 'No such file or directory - nosuchcommand' }, result)
    end
  end
end
