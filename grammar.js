/**
 * @file CCS is a language for config files, and libraries to read those files and configure applications.
 * @author Jacob Rice <jrice@drwholdings.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: 'ccs',

  extras: $ => [
    /\s/,
    $.line_comment,
    $.block_comment,
  ],

  rules: {
    source_file: $ => repeat($.statement),

    statement: $ => prec.left(0, seq(
      choice(
        $.directive,
        $.assignment,
        $.expression,
      ),
      optional(';')
    )),

    directive: $ => choice(
      seq('@import', $.string),
      seq('@constrain', $.statement),
      seq('@context', $.parens),
      seq('@override', $.statement),
    ),

    assignment: $ => seq(
      field('name', $.identifier),
      '=',
      field('value', choice($.number, $.boolean, $.string, $.identifier))
    ),

    expression: $ => prec.left(choice(
      $.identifier,
      $.number,
      $.boolean,
      $.string,
      $.block,
      $.parens,
      $.operator,
    )),

    operator: $ => choice(
      '.', ',', '>', ':', '|', '*'
    ),

    parens: $ => seq('(', repeat($.expression), ')'),

    block: $ => seq('{', repeat($.statement), '}'),

    line_comment: $ => token(seq('//', /.*/)),

    block_comment: $ => token(seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')),

    string: $ => choice(
      $._double_quoted_string,
      $._single_quoted_string
    ),

    _double_quoted_string: $ => token(seq(
      '"',
      repeat(choice(
        /[^"\\]/,
          /\\./,
          /\n/
        )),
      '"'
    )),

    _single_quoted_string: $ => token(seq(
      "'",
      repeat(choice(
        /[^'\\]/,
          /\\./,
          /\n/
        )),
      "'"
    )),

    boolean: $ => choice('true', 'false'),

    number: $ => token(choice(
      /[-+]?\d+\.\d+[eE][-+]?\d+/, // float w/ e-notation
      /[-+]?\d+\.\d*/,             // simple decimal
      /[-+]?\d+[eE][-+]?\d+/,      // integer w/ e-notation
      /[-+]?\d+/                   // integer
    )),

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,
  }
});
