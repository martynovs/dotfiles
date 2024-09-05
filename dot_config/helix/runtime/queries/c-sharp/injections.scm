; Verbatim copy of helix bundled c-sharp/injections.scm + LOCAL block.
; Source: helix-editor/helix runtime/queries/c-sharp/injections.scm

((comment) @injection.content
 (#set! injection.language "comment"))

;; LOCAL: parse /// XML doc comments as XML so tags get highlighted.
;; injection.combined merges consecutive /// lines so the parser sees a full
;; document and can match closing tags like </summary>.
((comment) @injection.content
 (#match? @injection.content "^///")
 (#set! injection.language "xml")
 (#set! injection.combined))
