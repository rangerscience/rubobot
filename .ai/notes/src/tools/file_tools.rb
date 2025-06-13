Minimized file_tools.rb defines five file operation tools:
1. List - Lists files/dirs in path
2. Read - Shows file contents
3. Write - Writes to file, creates dirs if needed
4. Edit - Replaces text in file
5. Find - Searches files by pattern

Security: Restricts access to sensitive files (.env, .mise.toml) via helper method 's'.
All tools inherit from Tool class with parameters and execute method.
Variable names minimized: R (restricted files), M (message), s (safe method), p (path), d (directory), c (content).