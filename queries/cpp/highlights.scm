; extends
; Sans « ; extends », ce fichier REMPLACERAIT les highlights C++ de nvim-treesitter
; (namespace, template, class… ne seraient plus colorés). Ici on ne fait qu'ajouter
; les modules C++20.

"module" @keyword
"export" @keyword
"import" @keyword

(module_declaration
  name: (module_name) @module)

(import_declaration
  name: (module_name) @module)
