# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../src/tools/list_files'

class TestListFiles < Minitest::Test
  def setup
    @tool = Tools::ListFiles.new
  end

  def test_list_files_in_existing_directory
    expected = [
      'test/fixtures/readme.txt',
      'test/fixtures/subfolder/'
    ]
    result = @tool.execute(path: 'test/fixtures/')
    assert_equal expected, result
  end
end
