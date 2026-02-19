module agent

fn test_skills_loader_empty() {
	loader := new_skills_loader('/nonexistent/path')
	skills := loader.load_all() or { []Skill{} }

	assert skills.len == 0
}

fn test_skills_loader_load_by_name_not_found() {
	loader := new_skills_loader('.')
	_ := loader.load_by_name('nonexistent') or { return }
}
