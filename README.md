### :lotus_position: Purpose

`cursor-git-ref-command.nvim` centers around git operations on the git ref (e.g. SHA-1) under the cursor. I'm using it together with [vim-fugitive](https://github.com/tpope/vim-fugitive) as a way of quickly using git refs.

All commands operate on the ref (e.g. SHA-1 or branch name) under the cursor position. In that situation you can, for example:

- Cherry-pick a commit from `:G log <another-branch>` and apply it to the current branch using `CursorCherryPickCommit`.
- Check-out a commit from `:G reflog` to go back to a previous state, for some reason, using `CursorCheckOutCommit`.
- Drop a commit from `:G log` that you no longer need, for instance when preparing commits for a PR, using `CursorDropCommit`.
- Reset the current branch to another commit, via `CursorResetCommitSoft`, `CursorResetCommitMixed` or `CursorResetCommitHard`.

Ideally there would also be a `CursorRewordCommit` to rephrase a commit's message, but I haven't found a way to work that functionality into a command similar to the others yet.

### :mechanic: Installation

Install example with the [Lazy](https://github.com/folke/lazy.nvim) package manager:

```lua
require("lazy").setup({
  {
    "oflisback/cursor-git-ref-command.nvim",
	config = function()
		require("cursor-git-ref-command").setup()
	end,
  }
})
```

### :keyboard: Commands

The plugin provides the following commands:

- **`CursorCherryPickCommit`**: Cherry-picks the commit at the cursor location.
- **`CursorCheckOutCommit`**: Checks out the commit at the cursor location.
- **`CursorDropCommit`**: Drops the commit at the cursor location.
- **`CursorResetCommitSoft`**: Soft resets to the commit at the cursor location.
- **`CursorResetCommitMixed`**: Mixed resets to the commit at the cursor location.
- **`CursorResetCommitHard`**: Hard resets to the commit at the cursor location.

### :people_holding_hands: Contributing

Contributions, bug reports and suggestions are very welcome.

If you have a suggestion that would make the project better, please fork the repo and create a pull request.
