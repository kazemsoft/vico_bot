module providers

import config

// new_provider_from_config creates a provider based on the configuration.
// Simple rules (v0):
//   - if OpenAI API key present -> OpenAI
//   - else fallback to stub
pub fn new_provider_from_config(cfg config.VicobotConfig) LLMProvider {
	if openai_cfg := cfg.providers.openai {
		if openai_cfg.api_key != '' {
			return new_openai_provider(openai_cfg.api_key, openai_cfg.api_base, openai_cfg.max_tokens)
		}
	}
	return new_stub_provider()
}
