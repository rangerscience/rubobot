require 'minitest/autorun'
require_relative '../src/tools/edit_file'

class TestEditFile < Minitest::Test
  def setup
    @tool = Tools::EditFile.new
  end

  def test_editing_an_existing_file
    Tempfile.create('foo') do |file|
      file.write('This is some content to edit')
      file.flush

      @tool.execute(path: file.path, old_str: 'content', new_str: 'text')
      assert_equal 'This is some text to edit', File.read(file.path)
    end
  end

  def test_editing_an_existing_file
    filename = Dir.tmpdir + '/foo.txt'
    raise "File #{filename} should not exist before test" if File.exist?(filename)

    @tool.execute(path: filename, old_str: '', new_str: 'Some fresh content')
    assert_equal 'Some fresh content', File.read(filename)
    File.delete(filename)
  end
end
