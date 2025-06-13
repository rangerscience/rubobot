RuboCop tools module with three classes:
1. Lint - Runs RuboCop linting with JSON output, formats results
   - Params: path (optional)
2. Autocorrect - Runs RuboCop autocorrection
   - Params: path (optional), safe (optional, default true)
3. ExplainOffense - Gets explanation for specific RuboCop cop
   - Params: cop_name (required)
Each tool uses system commands with bundle exec rubocop and proper flags.