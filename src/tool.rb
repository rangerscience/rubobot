class Tool < RubyLLM::Tool
  def execute(...)
    begin
      execute(...)
    rescue StandardError => e
      { error: e.message }
    end
  end
end