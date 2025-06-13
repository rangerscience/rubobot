The file_tools.rb defines six tools for file operations:
1. List - Lists files and directories in a specified path
2. Read - Reads contents of a file
3. Write - Writes content to a file (creates directories if needed)
4. Edit - Replaces text in a file using string substitution
5. Find - Searches for files matching a glob pattern

The module implements security by restricting access to sensitive files (.env, .mise.toml) through a helper method (renamed from 'unless_restricted' to 'safe').
Each tool inherits from Tool class and defines parameters and execute method.