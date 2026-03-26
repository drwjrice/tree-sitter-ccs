# tree-sitter-ccs Neovim setup

This repository contains the CCS tree-sitter grammar and its Neovim queries.

## Current recommended Neovim setup

The working setup with current `nvim-treesitter` is:

- register the parser in a `User TSUpdate` autocommand
- use a local checkout via `install_info.path`
- set `queries = "queries"` so `nvim-treesitter` installs or symlinks the query directory itself
- register the `.ccs` filetype if needed
- explicitly start highlighting with `vim.treesitter.start()` in a `FileType` autocmd or `ftplugin`

Manual symlinking into `lazy/nvim-treesitter/queries` is an older workaround and should not be needed with the current plugin.

## Example lazy.nvim configuration

```lua
local function register_custom_parsers()
  require("nvim-treesitter.parsers").ccs = {
    install_info = {
      path = vim.fn.expand("~/code/tree-sitter-ccs"),
      files = { "src/parser.c" },
      queries = "queries",
    },
    filetype = "ccs",
  }
end

vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",
  callback = register_custom_parsers,
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "ccs" },
    },
    config = function(_, opts)
      register_custom_parsers()
      require("nvim-treesitter").setup(opts)

      vim.filetype.add({ extension = { ccs = "ccs" } })
      vim.treesitter.language.register("ccs", "ccs")
    end,
  },
}
```

Then enable treesitter features explicitly for CCS buffers.

A copy-pasteable example is included at:

- `examples/nvim/ftplugin/ccs.lua`

If you prefer an autocmd instead of an `ftplugin`, the equivalent setup looks like this:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ccs" },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
```

The example `ftplugin/ccs.lua` also enables treesitter indentation and folding.

If you want the equivalent folding setup in an autocmd, it looks like this:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ccs" },
  callback = function()
    pcall(vim.treesitter.start)
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt_local.foldenable = false
  end,
})
```

## Why `vim.treesitter.start()` matters

Current `nvim-treesitter` docs describe parser and query installation, but highlighting itself is provided by Neovim and must be started explicitly per buffer.

If the parser is installed and the query file is present but the buffer still looks unhighlighted, check whether your config ever calls `vim.treesitter.start()` for `ccs` buffers.

## What changed from the older setup

Older instructions in this repo used manual query linking into:

- `~/.local/share/nvim/lazy/nvim-treesitter/queries/ccs`
- `~/.local/share/nvim/lazy/nvim-treesitter-context/queries/ccs`

That was a workaround for an older configuration approach.

With the current plugin:

- parser and queries are installed under `stdpath("data")/site`
- the active query path is typically:
  - `~/.local/share/nvim/site/queries/ccs/highlights.scm`
- this install dir is added to `runtimepath`

So the current query path is expected to be under `site/queries`, not inside the plugin checkout.

## Useful debugging commands

Inside Neovim, these are the most useful checks:

### Confirm the active query file

```lua
:lua =vim.api.nvim_get_runtime_file('queries/ccs/highlights.scm', true)
```

### Inspect captures and active highlight groups at the cursor

```vim
:Inspect
```

or:

```lua
:lua =vim.inspect_pos(0, vim.fn.line('.') - 1, vim.fn.col('.') - 1, {})
```

### Inspect the parse tree

```vim
:InspectTree
```

### Check captures at a specific 0-based position

```lua
:lua =vim.treesitter.get_captures_at_pos(0, row, col)
```

### Check whether the parser is attached

```lua
:lua =vim.treesitter.get_parser(0, 'ccs')
```

### Check installed parser and query locations

```lua
:lua =vim.api.nvim_get_runtime_file('parser/ccs.so', true)
:lua =vim.api.nvim_get_runtime_file('queries/ccs/highlights.scm', true)
```

## Common failure modes

### Parser installed, no visible highlighting

Usually one of these:

1. `vim.treesitter.start()` is never called for the buffer
2. your colorscheme links the dominant captures to colors close to `Normal`
3. the query file is loaded, but the grammar does not parse the text the way you expect

### Query path confusion

If you see `site/queries/ccs/highlights.scm`, that is normal for the current plugin.

### Theme makes captures look invisible

Use `:Inspect` on a token. If captures exist but the colors still look plain, the problem is usually your highlight group links, not the parser installation.

An example fix in your Neovim config is:

```lua
vim.api.nvim_set_hl(0, "@variable.ccs", { link = "@type" })
vim.api.nvim_set_hl(0, "@variable.definition.ccs", { link = "@property" })
vim.api.nvim_set_hl(0, "@operator.ccs", { link = "@keyword" })
vim.api.nvim_set_hl(0, "@constant.builtin.ccs", { link = "@constant" })
```

That kind of override belongs in your Neovim colorscheme or highlight config, not in the parser itself. The parser and query should describe structure; the editor config decides how those captures should look in your theme.

## Notes

- This grammar currently ships `queries/highlights.scm` and `queries/context.scm`.
- `package.json` already includes `queries/*` in published files.
- `tree-sitter.json` declares the `ccs` filetype.
