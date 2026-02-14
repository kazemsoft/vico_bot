module config

import os
import json

fn test_initialize_workspace_creates_files() {
	// Create a temporary directory for the test
	d := os.join_path(os.temp_dir(), 'picobot_test_ws')
	// Clean up if it already exists from a failed run
	if os.exists(d) {
		os.rmdir_all(d) or { panic(err) }
	}
	os.mkdir_all(d, mode: 0o755) or { panic(err) }

	initialize_workspace(d) or { assert false, 'initialize_workspace failed: ${err}' }

	// Check required files exist and are non-empty
	want := ['AGENTS.md', 'SOUL.md', 'USER.md', 'TOOLS.md', 'HEARTBEAT.md',
		os.join_path('memory', 'MEMORY.md')]
	for w in want {
		p := os.join_path(d, w)
		assert os.exists(p) == true

		content := os.read_file(p) or {
			assert false, 'failed to read ${p}'
			''
		}
		assert content.len > 0
	}

	// Verify folders were created
	assert os.is_dir(os.join_path(d, 'memory')) == true
	assert os.is_dir(os.join_path(d, 'skills')) == true

	// Cleanup
	os.rmdir_all(d) or { panic(err) }
}

fn test_save_and_load_config() {
	d := os.join_path(os.temp_dir(), 'picobot_test_cfg')
	if os.exists(d) {
		os.rmdir_all(d) or { panic(err) }
	}
	os.mkdir_all(d, mode: 0o755) or { panic(err) }

	mut cfg := default_config()
	cfg.agents.defaults.workspace = d
	path := os.join_path(d, 'config.json')

	save_config(cfg, path) or { assert false, 'save_config failed: ${err}' }

	// Verify file exists
	assert os.exists(path) == true

	// Load and parse
	content := os.read_file(path) or {
		assert false, 'reading saved config failed: ${err}'
		''
	}

	parsed := json.decode(VicobotConfig, content) or {
		assert false, 'invalid json: ${err}'
		VicobotConfig{}
	}

	// Assert equality
	assert parsed.agents.defaults.workspace == d

	// Verify provider defaults
	// In V, Option types (?) are checked with 'if val := parsed.providers.openai'
	if openai := parsed.providers.openai {
		assert openai.api_key == 'sk-or-v1-REPLACE_ME'
		println('[TEST] openai.api_base: ${openai.api_base}')
		assert openai.api_base == 'https://openrouter.ai/api/v1'
	} else {
		assert false, 'expected OpenAI config to be present'
	}

	// Cleanup
	os.rmdir_all(d) or { panic(err) }
}
