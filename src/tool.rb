class Tool < RubyLLM::Tool
  def execute(...)
    execute(...)
  rescue StandardError => e
    { error: e.message }
  end
end
