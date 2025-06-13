File defines bundler tool classes in Tools::Bundler module:
- Install: Installs dependencies from Gemfile with optional params (path, without, jobs)
- Update: Updates gems with optional params (gems, group, source)
- Add: Adds gem to Gemfile with optional version and group
- Remove: Removes gem from Gemfile
- List: Lists gems in bundle with optional name filter
- Info: Shows info for specific gem
- Outdated: Shows outdated gems with optional filter

Common patterns:
- All tools build shell commands with params
- Most tools prompt user for confirmation before execution
- All tools handle errors with rescue blocks
- Commands executed with backticks
- Success/failure determined by $?.success?
- Returns output.strip on success, error hash on failure

Potential RuboCop issues:
- String concatenation vs interpolation
- Use of backticks vs safer methods
- Inconsistent use of conditionals
- Global variable usage ($?)
- Error handling patterns
- Parameter validation patterns