local extract = {}

function extract.refs(line)
	local refs = {}

	local start_paren = line:find("%(")
	if not start_paren then
		return refs
	end

	local end_paren = line:find("%)", start_paren)
	if not end_paren then
		return refs
	end

	local refs_str = line:sub(start_paren + 1, end_paren - 1)

	for ref in refs_str:gmatch("[^,]+") do
		ref = ref:match("^%s*(.-)%s*$")

		-- If the ref contains " -> ", get the target ref
		local target_ref = ref:match("->%s*(.+)")
		if target_ref then
			ref = target_ref
		end

		if ref ~= "HEAD" and ref ~= "origin/HEAD" then
			table.insert(refs, ref)
		end
	end
	return refs
end

function extract.focused_word(line, cursor_pos)
	local start = cursor_pos
	while start > 0 and line:sub(start, start):match("%w") do
		start = start - 1
	end

	local finish = cursor_pos + 1
	while finish <= #line and line:sub(finish, finish):match("%w") do
		finish = finish + 1
	end

	return line:sub(start + 1, finish - 1), finish
end

function extract.cursor_hash(line, cursor_pos)
	local current_word, next_pos = extract.focused_word(line, cursor_pos)

	local commit_hash = current_word

	if current_word == "commit" then
		local start = next_pos
		while start <= #line and line:sub(start, start):match("%s") do
			start = start + 1
		end
		commit_hash, _ = extract.focused_word(line, start)
	end
	return commit_hash
end

function extract.cursor_hash_and_refs()
	local _, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()

	local commit_hash = extract.cursor_hash(line, col)

	local validate_commit_cmd = string.format("git cat-file -e %s 2>/dev/null", commit_hash)
	local is_valid_commit = vim.fn.system(validate_commit_cmd) == ""

	if not is_valid_commit then
		print("Invalid commit hash or not within a valid git repository: " .. commit_hash)
		return nil, {}
	end

	local refs = extract.refs(line)

	return commit_hash, refs
end

return extract
