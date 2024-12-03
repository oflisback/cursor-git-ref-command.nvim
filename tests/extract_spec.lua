local extract = require("cursor-git-ref-command.extract")

describe("extract", function()
	it("should extract focused word", function()
		assert.are.equal("first", extract.focused_word("first second third", 0))

		-- Go back towards previous word
		assert.are.equal("first", extract.focused_word("first second third", 5))
		assert.are.equal("second", extract.focused_word("first second third", 6))
		assert.are.equal("third", extract.focused_word("first second third", 13))
	end)

	it("should extract refs on line but ignore HEAD -> main and origin/HEAD", function()
		assert.are.same(
			{ "main", "some-random-branch", "origin/main", "origin/create-pull-request/patch" },
			extract.refs(
				"commit c6f6fb178ebe9b4fd90383de743c3399f8c3a37c (HEAD -> main, some-random-branch, origin/main, origin/create-pull-request/patch, origin/HEAD)"
			)
		)
		assert.are.same({}, extract.refs("commit c6f6fb178ebe9b4fd90383de743c3399f8c3a37c"))
	end)

	it("should extract cursor hash", function()
		local commit = "c6f6fb178ebe9b4fd90383de743c3399f8c3a37c"
		local line =
			"commit c6f6fb178ebe9b4fd90383de743c3399f8c3a37c (HEAD -> main, origin/main, origin/create-pull-request/patch, origin/HEAD)"
		assert.are.same(commit, extract.cursor_hash(line, 0))
		assert.are.same(commit, extract.cursor_hash(line, 10))
		assert.are.same(commit, extract.cursor_hash(line, 40))
	end)

	it("should extract tag", function()
		local commit = "0da890a2"
		local tag = "mytag"
		local line = commit .. " (tag: " .. tag .. ")"
		assert.are.same({ "mytag" }, extract.refs(line))
	end)

	it("should extract sha", function()
		local line = "113990c (origin/main, origin/HEAD) HEAD@{1}: commit (amend): Config"
		local commit = "113990c"
		assert.are.same({ "origin/main" }, extract.refs(line))
		assert.are.same(commit, extract.cursor_hash(line, 0))
	end)
end)
