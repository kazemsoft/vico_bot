module agent

import time
import providers

fn test_llm_ranker_basic() {
	mock_provider := providers.new_stub_provider()
	ranker := new_llm_ranker(mock_provider, 'test-model')

	memories := [
		MemoryItem{
			text:      'User asked about Python programming'
			kind:      'user'
			timestamp: time.now()
		},
		MemoryItem{
			text:      'User asked about V language'
			kind:      'user'
			timestamp: time.now()
		},
	]

	result := ranker.rank('Python programming', memories, 2)
	assert result.len <= 2
	assert result.len > 0
}

fn test_llm_ranker_empty_memories() {
	mock_provider := providers.new_stub_provider()
	ranker := new_llm_ranker(mock_provider, 'test-model')

	empty_memories := []MemoryItem{}
	result := ranker.rank('any query', empty_memories, 5)
	assert result.len == 0
}

fn test_llm_ranker_zero_top() {
	mock_provider := providers.new_stub_provider()
	ranker := new_llm_ranker(mock_provider, 'test-model')

	memories := [
		MemoryItem{
			text:      'Test memory'
			kind:      'user'
			timestamp: time.now()
		},
	]

	result := ranker.rank('query', memories, 0)
	assert result.len == 0
}

fn test_llm_ranker_fallback() {
	mock_provider := providers.new_stub_provider()
	ranker := new_llm_ranker(mock_provider, 'test-model')

	memories := [
		MemoryItem{
			text:      'Test memory 1'
			kind:      'user'
			timestamp: time.now()
		},
		MemoryItem{
			text:      'Test memory 2'
			kind:      'user'
			timestamp: time.now()
		},
	]

	result := ranker.rank('query', memories, 1)
	assert result.len == 1
}
