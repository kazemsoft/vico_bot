module providers

import time
import context

fn test_stub_provider_echo() {
	p := new_stub_provider()
	mut base_ctx := context.background()
	mut ctx, cancel := context.with_timeout(mut base_ctx, 1 * time.second)
	defer { cancel() }

	msgs := [Message{
		role:    'user'
		content: 'hello world'
	}]
	resp := p.chat(mut ctx, msgs, [], '') or { panic('expected no error, but got one') }

	assert resp.content != ''
	assert resp.content.contains('hello world')
}
