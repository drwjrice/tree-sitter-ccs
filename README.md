# lazy.nvim setup

Below is an example of my treesitter config file. I'm sure it's too complex, but I couldn't figure out a better way to install the queries and contexts from external Treesitter plugins, so I have lazy do it for me.

```lua
local function ft_by_extension(extension)
  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    pattern = { "*." .. extension },
    -- command = "set filetype=ccs",
    callback = function() vim.bo.filetype = extension end,
  })
end

local function exists(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
end

local function alert_if_not_exists(path)
  if not exists(path) then require "notify"(path .. " does not exist") end
end

-- Installing doesn't automatically link queries directory, so we do it here
local lazy_data = vim.fn.stdpath "data" .. "/lazy"

local function _link_query_into_plugin(parser_name, parser_plugin, destination_plugin_path)
  alert_if_not_exists(destination_plugin_path)
  local parser_queries = destination_plugin_path .. "/" .. parser_name
  local plugin_path = lazy_data .. "/" .. parser_plugin
  alert_if_not_exists(plugin_path)
  local plugin_queries = plugin_path .. "/queries"

  if exists(plugin_path) and exists(plugin_queries) and not exists(parser_queries) then
    require "notify"("Setting up " .. parser_name .. " queries")

    local command = "ln -s " .. plugin_queries .. " " .. parser_queries
    local success = os.execute(command)
    if not success then require "notify" "Failed to create symlink." end
  end
end

local function link_queries(parser_name, plugin_name)
  local queries_path = lazy_data .. "/nvim-treesitter/queries"
  _link_query_into_plugin(parser_name, plugin_name, queries_path)
end

local function link_context(parser_name, plugin_name)
  local context_path = lazy_data .. "/nvim-treesitter-context/queries"
  _link_query_into_plugin(parser_name, plugin_name, context_path)
end

---@type LazySpec
return {
  { "pest-parser/tree-sitter-pest" },
  { "drwjrice/tree-sitter-ccs" },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    opts = {
      ensure_installed = {
        ...
      },
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = true,
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      local parsers = require "nvim-treesitter.parsers"
      local parser_config = parsers.get_parser_configs()

      -- Custom parsers from github
      parser_config.ccs = {
        install_info = {
          url = "https://github.com/drwjrice/tree-sitter-ccs",
          files = { "src/parser.c" },
          branch = "main",
        },
      }

      ft_by_extension "ccs"
      link_queries("ccs", "tree-sitter-ccs")
      link_context("ccs", "tree-sitter-ccs") -- Optional; link to nvim-treesitter-context
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup {
        multiwindow = true,
        multiline_threshold = 10,
        mode = "topline",
        separator = "-",
      }
    end,
  },
}

```
