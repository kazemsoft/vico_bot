module config

import os
import json

// load_config loads config from ~/.vicobot/config.json if present.
// Returns an empty VicobotConfig if the file is missing, or an error if JSON is malformed.
pub fn load_config() !VicobotConfig {
	// Get home directory or fallback to current directory
	home := os.home_dir()

	// Join paths using os.join_path (replaces filepath.Join)
	path := os.join_path(home, '.vicobot', 'config.json')

	// Read the entire file content
	content := os.read_file(path) or {
		// If it exists but we can't read it, return default (matching Go logic)
		return VicobotConfig{}
	}

	// Decode JSON string into the Config struct
	// The '!' propagates the error if JSON is invalid
	cfg := json.decode(VicobotConfig, content)!

	return cfg
}
