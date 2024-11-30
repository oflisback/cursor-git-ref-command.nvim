### :lotus_position: Purpose

`cursor-git-ref-command.nvim` centers around git operations on the git ref (e.g. SHA-1) under the cursor. I'm using it together with [vim-fugitive](https://github.com/tpope/vim-fugitive) as a way of quickly using git refs.

All commands operate on the ref (e.g. SHA-1 or branch name) under the cursor position. In that situation you can, for example:

- Cherry-pick a commit from `:G log <another-branch>` and apply it to the current branch using `CursorCherryPick`.
- Check-out a commit from `:G reflog` to go back to a previous state, for some reason, using `CursorCheckOut`.
- Drop a commit from `:G log` that you no longer need, for instance when preparing commits for a PR, using `CursorDrop`.
- Reset the current branch to another commit, via `CursorResetSoft`, `CursorResetMixed` or `CursorResetHard`.

### :mechanic: Installation

Install example with the [Lazy](https://github.com/folke/lazy.nvim) package manager:

```lua
require("lazy").setup({
  {
    "oflisback/cursor-git-ref-command.nvim",
	config = function()
		require("cursor-git-ref-command").setup()
	end,
    dependencies = {
      "nvim-telescope/telescope.nvim"
    }
  }
})
```

### :keyboard: Commands

The plugin provides the following commands:

- **`CursorCherryPick`**: Cherry-picks the commit at the cursor location.
- **`CursorCheckOut`**: Checks out the commit at the cursor location.
- **`CursorDrop`**: Drops the commit at the cursor location.
- **`CursorResetSoft`**: Soft resets to the commit at the cursor location.
- **`CursorResetMixed`**: Mixed resets to the commit at the cursor location.
- **`CursorResetHard`**: Hard resets to the commit at the cursor location.

### :test_tube: Development

Tests are using https://github.com/lunarmodules/busted install via `luarocks install --local busted` and add `~/.luarocks/bin` to your PATH. After that run tests via `busted --helper=test_helper.lua tests`.

### :people_holding_hands: Contributing

Contributions, bug reports and suggestions are very welcome.

If you have a suggestion that would make the project better, please fork the repo and create a pull request.
