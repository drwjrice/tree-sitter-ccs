package tree_sitter_ccs_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_ccs "github.com/drwjrice/tree-sitter-ccs/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_ccs.Language())
	if language == nil {
		t.Errorf("Error loading CCS grammar")
	}
}
