; Highlights for CCS language in Tree-sitter

(line_comment) @comment
(block_comment) @comment

; directives and keywords
(directive "@import") @keyword.import
(directive "@constrain") @keyword
(directive "@context") @keyword
(directive "@override") @type.qualifier

(identifier) @variable
(number) @number
(boolean) @constant.builtin
(string) @string

(assignment name: (identifier) @variable.definition)
; (constraint (identifier) @type)

(operator) @operator
