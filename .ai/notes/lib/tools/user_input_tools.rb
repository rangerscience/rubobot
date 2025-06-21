UserInput tool summary:
- Located in lib/tools/user_input_tools.rb
- Implements Tools::UserInput::Request class that extends Tool base class
- Functionality: Requests input from the user with a prompt and optional default value
- Parameters:
  - prompt: The text to show to the user (required)
  - default: Optional default value to suggest (optional)
- Returns user input or default value if input is empty and default is provided
- Already properly implemented with error handling through Tool base class