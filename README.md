### :lotus_position: Purpose

`cursor-git-ref-command.nvim` centers around git operations on the git ref or sha under the cursor or on the current line. I'm using it together with [vim-fugitive](https://github.com/tpope/vim-fugitive) as a way to quickly operate based on refs or sha:s.

For example it can be used to:

- Cherry-pick a commit from `:G log <another-branch>` and apply it to the current branch using `CursorCherryPick`.
- Check-out a commit or branch from `:G reflog` to go back to a previous state, for some reason, using `CursorCheckOut`.
- Drop a commit from `:G log` that you no longer need, for instance when preparing commits for a PR, using `CursorDrop`.
- Reset the current branch to another commit, via `CursorResetSoft`, `CursorResetMixed` or `CursorResetHard`.

If there's more than one commit or ref on the cursor line, a telescope picker is used for selecting the desired one, such as in this example:

```
commit ab9cfc4dc3422af5235759efef456d3e02745217 (HEAD -> master, origin/master, origin/HEAD)
```

where you'd often want to check out `master` and not `ab9cfc4dc3422af5235759efef456d3e02745217`.

Example workflow:

1. Open git log in buffer
2. Move cursor to a commit line such as:

```
commit ab9cfc4dc3422af5235759efef456d3e02745217 (HEAD -> master, origin/master, origin/HEAD)
```

3. Run e.g. `:CursorResetHard` (preferrably via some key binding :) to reset your working tree to that commit.

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

- **`CursorCherryPick`**: Cherry-pick commit at the cursor line.
- **`CursorCheckOut`**: Check out commit or ref at the cursor line.
- **`CursorDrop`**: Drop commit at the cursor line.
- **`CursorResetSoft`**: Soft reset to the commit or ref at the cursor line.
- **`CursorResetMixed`**: Mixed reset to the commit or ref at the cursor line.
- **`CursorResetHard`**: Hard reset to the commit or ref at the cursor line.

### :test_tube: Development

Tests are using https://github.com/lunarmodules/busted install via `luarocks install --local busted` and add `~/.luarocks/bin` to your PATH. After that run tests via `busted --helper=test_helper.lua tests`.

### :people_holding_hands: Contributing

Contributions, bug reports and suggestions are very welcome.

If you have a suggestion that would make the project better, please fork the repo and create a pull request.
