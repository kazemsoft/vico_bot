module config

import os
import json

// default_config returns a minimal default AppConfiguration with sensible defaults.
pub fn default_config() VicobotConfig {
	return VicobotConfig{
		agents:    AgentsConfig{
			defaults: AgentDefaults{
				workspace:            '~/.vicobot/workspace'
				model:                'stub-model'
				max_tokens:           8192
				temperature:          0.7
				max_tool_iterations:  100
				heartbeat_interval_s: 60
			}
		}
		channels:  ChannelsConfig{
			telegram: TelegramConfig{
				enabled:    false
				token:      ''
				allow_from: []
			}
		}
		providers: ProvidersConfig{
			openai: ProviderConfig{
				api_key:  'sk-or-v1-REPLACE_ME'
				api_base: 'https://openrouter.ai/api/v1'
			}
		}
	}
}

// save_config writes the config to the given path (creating parent dirs).
pub fn save_config(cfg VicobotConfig, path string) ! {
	dir := os.dir(path)
	if !os.exists(dir) {
		os.mkdir_all(dir, mode: 0o755)!
	}
	// json.encode_pretty provides indented output
	b := json.encode_pretty(cfg)
	os.write_file(path, b)!
	os.chmod(path, 0o640) or { panic('Failed to set permissions') }
}

// initialize_workspace creates the workspace dir and bootstrap files.
pub fn initialize_workspace(base_path string) ! {
	if !os.exists(base_path) {
		os.mkdir_all(base_path, mode: 0o755)!
	}

	// Full content mapping for bootstrap files
	files := {
		'SOUL.md':      '# Soul

I am vicobot 🤖, a personal AI assistant.

## Personality

- Helpful and friendly
- Concise and to the point
- Curious and eager to learn

## Values

- Accuracy over speed
- User privacy and safety
- Transparency in actions

## Communication Style

- Be clear and direct
- Explain reasoning when helpful
- Ask clarifying questions when needed
'
		'AGENTS.md':    '# Agent Instructions

You are a helpful AI assistant. Be concise, accurate, and friendly.

## Guidelines

- Always explain what you\'re doing before taking actions
- Ask for clarification when the request is ambiguous
- Use tools to help accomplish tasks
- Remember important information using the write_memory tool

## File Creation

When the user asks you to create files, code, projects, or any deliverable:

1. Always create them inside the workspace directory
2. Create a project folder with the naming convention: project-YYYYMMDD-HHMMSS-TASKNAME
   - YYYYMMDD-HHMMSS is the current date and time
   - TASKNAME is a short lowercase slug describing the task (e.g. landing-page, python-scraper, budget-tracker)
3. Create all files inside that project folder
4. Use the filesystem tool with action "write" for each file
5. After creating all files, list the project folder to confirm

Example: if the user says "create a landing page for my coffee shop", create:
  project-20260208-143000-coffee-landing/
    index.html
    style.css
    script.js

Never create files directly in the workspace root. Always use a project folder.

## Memory

- Use the write_memory tool with target "today" for daily notes
- Use the write_memory tool with target "long" for long-term information
- Do NOT just say you\'ll remember something — actually call write_memory

## Skills

- You can create new skills with the create_skill tool
- Skills are reusable knowledge/procedures stored in skills/
- List available skills with list_skills before creating duplicates

## Safety

- Never execute dangerous commands (rm -rf, format, dd, shutdown)
- Ask for confirmation before destructive file operations
- Do not expose API keys or credentials in responses
'
		'USER.md':      "# User Profile

Information about the user to help personalize interactions.

## Basic Information

- **Name**: (your name)
- **Timezone**: (your timezone, e.g., UTC+8)
- **Language**: (preferred language)

## Preferences

### Communication Style

- [ ] Casual
- [x] Professional
- [ ] Technical

### Response Length

- [x] Brief and concise
- [ ] Adaptive based on question
- [ ] Detailed explanations

### Technical Level

- [ ] Beginner
- [x] Intermediate
- [ ] Expert

## Work Context

- **Primary Role**: (your role, e.g., developer, researcher)
- **Main Projects**: (what you're working on)
- **Tools You Use**: (IDEs, languages, frameworks)

## Topics of Interest

- (add your interests here)
"
		'TOOLS.md':     '# Available Tools

This document describes the tools available to vicobot.

## File Operations

### filesystem
Read, write, and list files in the workspace.
- action: "read", "write", "list"
- path: file or directory path (relative to workspace)
- content: (for "write" action) the content to write

Examples:
- Read: {"action": "read", "path": "data.csv"}
- Write: {"action": "write", "path": "data.csv", "content": "Name\\nBen\\nKen\\n"}
- List: {"action": "list", "path": "."}

## Shell Execution

### exec
Execute a shell command and return output.
- command: the shell command to run
- Commands have a timeout (default 60s)
- Dangerous commands are blocked

## Web Access

### web
Fetch and extract content from a URL.
- url: the URL to fetch
- Useful for checking websites, APIs, documentation

## Messaging

### message
Send a message to the current channel/chat.
- content: the message text

## Memory

### write_memory
Persist information to memory files.
- target: "today" (daily notes) or "long" (long-term memory)
- content: what to remember
- append: true to add, false to replace

## Skill Management

### create_skill
Create a new skill in the skills/ directory.
- name: skill name (used as folder name)
- description: brief description
- content: the skill\'s markdown content

### list_skills
List all available skills. No arguments needed.

### read_skill
Read a specific skill\'s content.
- name: the skill name to read

### delete_skill
Delete a skill from skills/.
- name: the skill name to delete

## Background Tasks

### spawn
Spawn a background subagent process.

### cron
Schedule or manage cron jobs.
'
		'HEARTBEAT.md': '# Heartbeat

This file is checked periodically (every 60 seconds). Add tasks here that should run on a schedule.

## Periodic Tasks

<!-- Add tasks below. The agent will process them on each heartbeat check. -->
<!-- Example:
- Check server status at https://example.com/health
- Summarize unread messages
-->
'
	}

	for name, content in files {
		p := os.join_path(base_path, name)
		if !os.exists(p) {
			os.write_file(p, content)!
		}
	}

	// Memory directory
	mem_dir := os.join_path(base_path, 'memory')
	if !os.exists(mem_dir) {
		os.mkdir_all(mem_dir, mode: 0o755)!
	}

	mm_file := os.join_path(mem_dir, 'MEMORY.md')
	if !os.exists(mm_file) {
		os.write_file(mm_file, '# Long-term Memory\n\nImportant facts and information to remember across sessions.\n')!
	}

	// Skills directory
	skills_dir := os.join_path(base_path, 'skills')
	if !os.exists(skills_dir) {
		os.mkdir_all(skills_dir, mode: 0o755)!
	}
}

// resolve_default_paths returns absolute paths based on the user's home directory.
pub fn resolve_default_paths() !(string, string) {
	home := os.home_dir()
	if home == '' {
		return error('could not find home directory')
	}
	cfg_path := os.join_path(home, '.vicobot', 'config.json')
	ws_path := os.join_path(home, '.vicobot', 'workspace')
	return cfg_path, ws_path
}

// onboard is the main entry point to set up a new user environment.
pub fn onboard() !(string, string) {
	cfg_path, ws_path := resolve_default_paths()!

	// Create default config if missing
	if !os.exists(cfg_path) {
		cfg := default_config()
		save_config(cfg, cfg_path)!
	}

	// Initialize workspace files
	initialize_workspace(ws_path)!

	return cfg_path, ws_path
}
