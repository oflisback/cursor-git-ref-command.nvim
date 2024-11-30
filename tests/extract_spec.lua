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
			{ "main", "origin/main", "origin/create-pull-request/patch" },
			extract.refs(
				"commit c6f6fb178ebe9b4fd90383de743c3399f8c3a37c (HEAD -> main, origin/main, origin/create-pull-request/patch, origin/HEAD)"
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
end)
