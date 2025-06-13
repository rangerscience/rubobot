# Ruby Coding Agent

A powerful coding assistant implemented in Ruby that leverages Large Language Models through the RubyLLM library.

## Overview

This project provides an interactive coding agent that can help with various programming tasks. It uses Anthropic's Claude API by default but can be configured to work with other LLM providers.

## Features

- Interactive chat interface for natural language programming assistance
- Tool-based architecture for executing commands and manipulating files
- Rate limiting to prevent API usage spikes
- Support for custom instructions and prompts
- Docker support for easy deployment

## Requirements

- Ruby 3.x
- Bundler
- Anthropic API key (or another provider supported by RubyLLM)

## Installation

### Setting up Environment Variables

1. Copy the example environment file:
   ```
   cp .env.example .env
   ```

2. Edit `.env` and add your Anthropic API key:
   ```
   ANTHROPIC_API_KEY=your_key_here
   ```

### Installation Options

#### Using Docker (Recommended)

If you have Docker installed, you can run the agent without installing Ruby or any dependencies:

```bash
./run_in_docker.sh
```

The directory from which you run the script will be mounted into the container as `/workspace` and will be the working directory for the coding agent.

#### Without Docker

1. Make sure you have Ruby and Bundler installed
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Run the agent:
   ```bash
   ruby run.rb [working_directory]
   ```
   If no working directory is specified, the current directory will be used.

## Usage

Once the agent is running, you can interact with it through the command line:

- Type your questions or instructions and press Enter
- Type `exit` to quit the agent
- Type `reset` to reset the conversation
- Type `usage` to display token usage statistics

### Custom Instructions

You can provide custom instructions for the agent by creating a `.ai/instructions.txt` file in your working directory.

### Custom Prompt

You can set an initial prompt by creating a `.ai/prompt.txt` file in your working directory. This will be sent to the model when the agent starts.

## Configuration

The default configuration uses Claude 3 Sonnet, but you can modify `run.rb` to use different models or providers. See the [RubyLLM configuration documentation](https://rubyllm.com/configuration) for details.

## Running Tests

To run the test suite:

```bash
test/run_all.sh
```

## License

This project is licensed under the terms of the LICENSE file included in the repository.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.