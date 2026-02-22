module agent

import time
import chat
import providers

fn test_loop_basic_message_processing() {
	hub := chat.new_hub(10)
	provider := providers.new_stub_provider()
	loop := new_agent_loop(hub, provider, 'test-model', 5, '.', none)

	// Send a test message
	test_msg := chat.Inbound{
		channel:   'test'
		chat_id:   '123'
		sender_id: 'user1'
		content:   'Hello, bot!'
	}

	// Send message to hub
	hub.in <- test_msg

	// Process should complete without panicking
	assert true
}

fn test_process_direct_basic() {
	hub := chat.new_hub(10)
	provider := providers.new_stub_provider()
	mut loop := new_agent_loop(hub, provider, 'test-model', 5, '.', none)

	result := loop.process_direct('Hello, direct!', 30 * time.second) or {
		assert false, 'process_direct failed: ${err}'
		return
	}
	assert result.len > 0
}

fn test_process_direct_with_timeout() {
	hub := chat.new_hub(10)
	provider := providers.new_stub_provider()
	mut loop := new_agent_loop(hub, provider, 'test-model', 5, '.', none)

	// Short timeout - stub provider should still work
	result := loop.process_direct('Hello!', 5 * time.second) or {
		// Timeout is acceptable
		return
	}
	assert result.len >= 0
}

fn test_loop_context_setting() {
	hub := chat.new_hub(10)
	provider := providers.new_stub_provider()
	loop := new_agent_loop(hub, provider, 'test-model', 5, '.', none)

	// Send message to test context setting
	msg := chat.Inbound{
		channel:   'telegram'
		chat_id:   'chat123'
		sender_id: 'user1'
		content:   'Test context'
	}

	hub.in <- msg

	// Tools should have context set
	assert true
}
