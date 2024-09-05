; Verbatim copy of helix bundled c-sharp/highlights.scm + LOCAL block at end.
; Cannot use `inherits: c-sharp` (Helix self-recurses, crashes).
; See helix-editor/helix issue 14950.
; Resync the body verbatim on Helix upgrades; LOCAL block is ours to maintain.
; Upstream: helix-editor/helix runtime/queries/c-sharp/highlights.scm

(identifier) @variable

;; Methods

(method_declaration name: (identifier) @function)
(local_function_statement name: (identifier) @function)

;; Types

(interface_declaration name: (identifier) @type)
(class_declaration name: (identifier) @type)
(enum_declaration name: (identifier) @type)
(struct_declaration (identifier) @type)
(record_declaration (identifier) @type)
(namespace_declaration name: (identifier) @namespace)

(generic_name (identifier) @type)
(type_parameter (identifier) @type.parameter)
(parameter type: (identifier) @type)
(type_argument_list (identifier) @type)
(as_expression right: (identifier) @type)
(is_expression right: (identifier) @type)

(constructor_declaration name: (identifier) @constructor)
(destructor_declaration name: (identifier) @constructor)

(_ type: (identifier) @type)

(base_list (identifier) @type)

(predefined_type) @type.builtin

;; Enum
(enum_member_declaration (identifier) @type.enum.variant)

;; Literals

(real_literal) @constant.numeric.float
(integer_literal) @constant.numeric.integer
(character_literal) @constant.character

[
  (string_literal)
  (raw_string_literal)
  (verbatim_string_literal)
  (interpolated_string_expression)
  (interpolation_start)
  (interpolation_quote)
 ] @string

(escape_sequence) @constant.character.escape

(boolean_literal) @constant.builtin.boolean
(null_literal) @constant.builtin

;; Comments

(comment) @comment

;; Tokens

[
  ";"
  "."
  ","
] @punctuation.delimiter

[
  "--"
  "-"
  "-="
  "&"
  "&="
  "&&"
  "+"
  "++"
  "+="
  "<"
  "<="
  "<<"
  "<<="
  "="
  "=="
  "!"
  "!="
  "=>"
  ">"
  ">="
  ">>"
  ">>="
  ">>>"
  ">>>="
  "|"
  "|="
  "||"
  "?"
  "??"
  "??="
  "^"
  "^="
  "~"
  "*"
  "*="
  "/"
  "/="
  "%"
  "%="
  ":"
] @operator

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
  (interpolation_brace)
]  @punctuation.bracket

;; Keywords

[
  (modifier)
  "this"
  (implicit_type)
] @keyword

[
  "add"
  "alias"
  "as"
  "base"
  "break"
  "catch"
  "checked"
  "class"
  "continue"
  "default"
  "delegate"
  "do"
  "enum"
  "event"
  "explicit"
  "extern"
  "finally"
  "for"
  "foreach"
  "global"
  "goto"
  "implicit"
  "interface"
  "is"
  "lock"
  "namespace"
  "notnull"
  "operator"
  "params"
  "return"
  "remove"
  "sizeof"
  "stackalloc"
  "static"
  "struct"
  "throw"
  "try"
  "typeof"
  "unchecked"
  "using"
  "while"
  "new"
  "await"
  "in"
  "yield"
  "get"
  "set"
  "when"
  "out"
  "ref"
  "from"
  "where"
  "select"
  "record"
  "init"
  "with"
  "let"
] @keyword

[
  "case"
  "else"
  "if"
  "switch"
  "when"
] @keyword.control.conditional

;; Attribute

(attribute name: (identifier) @attribute)

;; Parameters

(parameter
  name: (identifier) @variable.parameter)

;; Type constraints

(type_parameter_constraints_clause (identifier) @type.parameter)

;; Method calls

(invocation_expression (member_access_expression name: (identifier) @function))

;; LOCAL BEGIN
;; Qualified type references like `Foo.Bar` (bundled only handles single identifier).
(qualified_name (identifier) @type)
;; `using Serilog;` — tag the imported name as a type so it matches qualified using paths.
(using_directive (identifier) @type)
;; Method return type when it's a single identifier (bundled `_ type:` doesn't fire on `returns:` field).
(method_declaration returns: (identifier) @type)
;; Object initializer LHS `Property = ...` inside `new Foo { ... }` — treat as member definition.
(initializer_expression
  (assignment_expression
    left: (identifier) @variable.other.member.declaration))
;; Property / field / event declaration names — member definitions.
(property_declaration name: (identifier) @variable.other.member.declaration)
(event_declaration name: (identifier) @variable.other.member.declaration)
(field_declaration
  (variable_declaration
    (variable_declarator (identifier) @variable.other.member.declaration)))
;; Property/field access `obj.Value` — tag as member access.
(member_access_expression name: (identifier) @variable.other.member)
;; Method calls and method definitions get the method scope (bundled tags them as plain functions).
(invocation_expression
  (member_access_expression
    name: (identifier) @function.method))
(method_declaration name: (identifier) @function.method)
(local_function_statement name: (identifier) @function.method)
;; Access modifiers `public/private/internal/readonly/...` → storage modifier scope.
(modifier) @keyword.storage.modifier
;; String quote characters — color delimiters separately from the content.
(string_literal "\"" @string.quote)
(interpolated_string_expression "\"" @string.quote)
(interpolation_start) @string.quote
(interpolation_quote) @string.quote
;; LOCAL END
