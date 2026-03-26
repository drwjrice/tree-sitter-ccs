#!/bin/bash

set -euo pipefail

site_dir="${1:-$HOME/.local/share/nvim/site}"

mkdir -p "${site_dir}/queries/ccs"
cp queries/highlights.scm "${site_dir}/queries/ccs/"

if [ -f queries/context.scm ]; then
  cp queries/context.scm "${site_dir}/queries/ccs/"
fi

cat <<EOF
Copied CCS queries into:
  ${site_dir}/queries/ccs

This helper is mainly for debugging or manual overrides.
With current nvim-treesitter, the preferred setup is to register the parser with:
  install_info.path = '~/code/tree-sitter-ccs'
  queries = 'queries'

That lets nvim-treesitter manage the active query path automatically.
EOF
