module config

// VicobotConfig holds vicobot configuration.
pub struct VicobotConfig {
pub mut:
	agents AgentsConfig @[json: 'agents']
pub:
	channels  ChannelsConfig  @[json: 'channels']
	providers ProvidersConfig @[json: 'providers']
}

pub struct AgentsConfig {
pub mut:
	defaults AgentDefaults @[json: 'defaults']
}

pub struct AgentDefaults {
pub mut:
	workspace string @[json: 'workspace']
pub:
	model                string @[json: 'model']
	max_tokens           int    @[json: 'maxTokens']
	temperature          f64    @[json: 'temperature']
	max_tool_iterations  int    @[json: 'maxToolIterations']
	heartbeat_interval_s int    @[json: 'heartbeatIntervalS']
}

pub struct ChannelsConfig {
pub:
	telegram TelegramConfig @[json: 'telegram']
}

pub struct TelegramConfig {
pub:
	enabled    bool     @[json: 'enabled']
	token      string   @[json: 'token']
	allow_from []string @[json: 'allowFrom']
}

pub struct ProvidersConfig {
pub:
	// In V, use '?' for optional fields (replaces Go pointers)
	openai ?ProviderConfig @[json: 'openai']
}

pub struct ProviderConfig {
pub:
	api_key    string @[json: 'apiKey']
	api_base   string @[json: 'apiBase']
	max_tokens int    @[json: 'maxTokens']
}
