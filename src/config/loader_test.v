module config

import os

const test_counter = 0

fn test_load_config_missing_file() {
	// Test when config file doesn't exist - should return default Config
	original_home := os.home_dir()

	// Create a temporary directory for testing
	temp_dir := os.temp_dir() + '/vicobot_test_${test_counter}'
	os.mkdir_all(temp_dir, mode: 0o700) or {
		assert false
		'Failed to create temp dir'
	}
	defer { os.rmdir_all(temp_dir) or {} }

	// Print created directory for debugging
	println('The tmp dir is ${temp_dir}')

	// Set home to our temp directory
	os.setenv('HOME', temp_dir, true)

	// Call load_config - should return default Config since file doesn't exist
	cfg := load_config() or { panic('Should not return error for missing file') }

	// Verify it's a default config (empty structs)
	assert cfg.agents.defaults.workspace == ''
	assert cfg.channels.telegram.enabled == false
	assert cfg.channels.telegram.token == ''
	assert cfg.providers.openai == none

	// Restore original HOME
	os.setenv('HOME', original_home, true)
}

fn test_load_config_valid_json() {
	original_home := os.home_dir()

	// Create a temporary directory for testing
	temp_dir := os.temp_dir() + '/vicobot_test_${test_counter}'
	os.mkdir_all(temp_dir) or { panic('Failed to create temp dir') }
	defer { os.rmdir_all(temp_dir) or {} }

	// Create .vicobot directory
	picobot_dir := os.join_path(temp_dir, '.vicobot')
	os.mkdir_all(picobot_dir) or { panic('Failed to create .vicobot dir') }

	// Create valid config file
	config_path := os.join_path(picobot_dir, 'config.json')
	valid_config := '{
		"agents": {
			"defaults": {
				"workspace": "/test/workspace",
				"model": "gpt-4",
				"maxTokens": 2048,
				"temperature": 0.7,
				"maxToolIterations": 10,
				"heartbeatIntervalS": 30
			}
		},
		"channels": {
			"telegram": {
				"enabled": true,
				"token": "test_token_123",
				"allowFrom": ["user1", "user2"]
			}
		},
		"providers": {
			"openai": {
				"apiKey": "sk-test-key",
				"apiBase": "https://api.openai.com/v1"
			}
		}
	}'

	os.write_file(config_path, valid_config) or { panic('Failed to write config file') }

	// Set home to our temp directory
	os.setenv('HOME', temp_dir, true)

	// Call load_config
	cfg := load_config() or { panic('Should not return error for valid JSON') }

	// Verify loaded config
	assert cfg.agents.defaults.workspace == '/test/workspace'
	assert cfg.agents.defaults.model == 'gpt-4'
	assert cfg.agents.defaults.max_tokens == 2048
	assert cfg.agents.defaults.temperature == 0.7
	assert cfg.agents.defaults.max_tool_iterations == 10
	assert cfg.agents.defaults.heartbeat_interval_s == 30

	assert cfg.channels.telegram.enabled == true
	assert cfg.channels.telegram.token == 'test_token_123'
	assert cfg.channels.telegram.allow_from.len == 2
	assert cfg.channels.telegram.allow_from[0] == 'user1'
	assert cfg.channels.telegram.allow_from[1] == 'user2'

	assert cfg.providers.openai != none
	openai_config := cfg.providers.openai or { panic('OpenAI config should not be none') }
	assert openai_config.api_key == 'sk-test-key'
	assert openai_config.api_base == 'https://api.openai.com/v1'

	// Restore original HOME
	os.setenv('HOME', original_home, true)
}

fn test_load_config_malformed_json() {
	original_home := os.home_dir()

	// Create a temporary directory for testing
	temp_dir := os.temp_dir() + '/vicobot_test_${test_counter}'
	os.mkdir_all(temp_dir) or { panic('Failed to create temp dir') }
	defer { os.rmdir_all(temp_dir) or {} }

	// Create .vicobot directory
	picobot_dir := os.join_path(temp_dir, '.vicobot')
	os.mkdir_all(picobot_dir) or { panic('Failed to create .vicobot dir') }

	// Create malformed config file
	config_path := os.join_path(picobot_dir, 'config.json')
	malformed_config := '{
		"agents": {
			"defaults": {
				"workspace": "/test/workspace",
				"model": "gpt-4",
				"maxTokens": 2048,
				"temperature": 0.7,
				"maxToolIterations": 10,
				"heartbeatIntervalS": 30
			}
		},
		"channels": {
			"telegram": {
				"enabled": true,
				"token": "test_token_123",
				"allowFrom": ["user1", "user2"
			}
		},
		"providers": {
			"openai": {
				"apiKey": "sk-test-key",
				"apiBase": "https://api.openai.com/v1"
			}
		}
	}' // Missing closing bracket in allowFrom array

	os.write_file(config_path, malformed_config) or { panic('Failed to write config file') }

	// Set home to our temp directory
	os.setenv('HOME', temp_dir, true)

	// Call load_config - should return error for malformed JSON
	load_config() or {
		// Expected error case - test passes
		return
	}
	assert false // Should not reach here if error was properly returned

	// Restore original HOME
	os.setenv('HOME', original_home, true)
}

fn test_load_config_partial_config() {
	original_home := os.home_dir()

	// Create a temporary directory for testing
	temp_dir := os.temp_dir() + '/vicobot_test_${test_counter}'
	os.mkdir_all(temp_dir) or { panic('Failed to create temp dir') }
	defer { os.rmdir_all(temp_dir) or {} }

	// Create .vicobot directory
	picobot_dir := os.join_path(temp_dir, '.vicobot')
	os.mkdir_all(picobot_dir) or { panic('Failed to create .vicobot dir') }

	// Create partial config file (only some fields)
	config_path := os.join_path(picobot_dir, 'config.json')
	partial_config := '{
		"agents": {
			"defaults": {
				"workspace": "/test/workspace",
				"model": "gpt-4"
			}
		},
		"channels": {
			"telegram": {
				"enabled": true
			}
		}
	}'

	os.write_file(config_path, partial_config) or { panic('Failed to write config file') }

	// Set home to our temp directory
	os.setenv('HOME', temp_dir, true)

	// Call load_config
	cfg := load_config() or { panic('Should not return error for partial JSON') }

	// Verify loaded partial config
	assert cfg.agents.defaults.workspace == '/test/workspace'
	assert cfg.agents.defaults.model == 'gpt-4'
	// Other fields should have default zero values
	assert cfg.agents.defaults.max_tokens == 0
	assert cfg.agents.defaults.temperature == 0.0

	assert cfg.channels.telegram.enabled == true
	assert cfg.channels.telegram.token == '' // default empty string
	assert cfg.channels.telegram.allow_from.len == 0 // default empty array

	assert cfg.providers.openai == none // not specified in config

	// Restore original HOME
	os.setenv('HOME', original_home, true)
}
