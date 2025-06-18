# Rubobot Command Line Tool

Rubobot is a command line tool that allows you to interact with an AI assistant for Ruby development tasks.

## Installation

1. Make sure you have Ruby installed on your system
2. Clone this repository
3. Install dependencies:
   ```
   bundle install
   ```
4. Set up your API key:
   Create a `.env` file in the project root with your Anthropic API key:
   ```
   ANTHROPIC_API_KEY=your_api_key_here
   ```
5. Make the tool accessible:
   - Option 1: Add the project directory to your PATH
   - Option 2: Create a symlink to the `rubobot` script from a directory in your PATH:
     ```
     sudo ln -s $(pwd)/rubobot /usr/local/bin/rubobot
     ```

## Usage

```
rubobot "Your prompt here"
```

Example:
```
rubobot "Check if my Gemfile has the latest version of Rails"
```

## Features

- Access to Ruby development tools including:
  - RuboCop for code linting and fixing
  - Git for version control
  - Bundler for gem management
  - File operations
- Natural language interface for Ruby development tasks
- Powered by Claude AI

## Requirements

- Ruby 2.7 or higher
- Anthropic API key