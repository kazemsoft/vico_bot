module providers

import config

fn test_new_provider_from_config_picks_openai() {
	// Create config with OpenAI provider configured
	mut cfg := config.VicobotConfig{
		providers: config.ProvidersConfig{
			openai: config.ProviderConfig{
				api_key:  'test-key'
				api_base: 'https://api.openai.com/v1'
			}
		}
	}
	p := new_provider_from_config(cfg)
	assert p is OpenAIProvider
}

fn test_new_provider_from_config_fallbacks_to_stub() {
	// Create config with no providers configured
	cfg := config.VicobotConfig{}
	p := new_provider_from_config(cfg)
	assert p is StubProvider
}

fn test_new_provider_from_config_fallbacks_to_stub_when_empty_api_key() {
	// Create config with OpenAI provider but empty API key
	mut cfg := config.VicobotConfig{
		providers: config.ProvidersConfig{
			openai: config.ProviderConfig{
				api_key:  ''
				api_base: 'https://api.openai.com/v1'
			}
		}
	}
	p := new_provider_from_config(cfg)
	assert p is StubProvider
}
