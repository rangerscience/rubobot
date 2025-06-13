# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../src/tools/read_file'

class TestReadFile < Minitest::Test
  def setup
    @tool = Tools::ReadFile.new
  end

  def test_read_existing_file
    expected = <<~TEXT
      The cake is a lie!
    TEXT
    result = @tool.execute(path: 'test/fixtures/readme.txt')
    assert_equal expected, result
  end

  def test_read_missing_file
    expected = { error: 'No such file or directory @ rb_sysopen - test/fixtures/missing.txt' }
    result = @tool.execute(path: 'test/fixtures/missing.txt')
    assert_equal expected, result
  end
end
