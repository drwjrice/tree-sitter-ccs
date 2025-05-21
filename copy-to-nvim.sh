#!/bin/bash

set -euo pipefail

nvim_plugins="${1:-$HOME/.local/share/nvim/lazy}"

if [ ! -d "${nvim_plugins}/nvim-treesitter" ]; then
  echo "${nvim_plugins}/nvim-treesitter does not exist!" 1>&2
  exit 1
fi

query_dir="${nvim_plugins}/nvim-treesitter/queries/ccs"
mkdir -p "${query_dir}"
cp queries/highlights.scm "${query_dir}"

if [ -d "${nvim_plugins}/nvim-treesitter-context" ]; then
  context_dir="${nvim_plugins}/nvim-treesitter-context/queries/ccs"
  mkdir -p "${context_dir}"
  cp queries/context.scm "${context_dir}"
fi
