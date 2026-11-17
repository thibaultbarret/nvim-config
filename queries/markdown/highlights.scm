; extends
; Masque les marqueurs de titre (#, ##, ###…) là où le conceal est actif :
; fenêtres de doc LSP de noice (K, doc de complétion), qui ont conceallevel = 3.
; Sans effet dans les fichiers .md ouverts normalement (conceallevel = 0).

((atx_h1_marker) @conceal (#set! conceal ""))
((atx_h2_marker) @conceal (#set! conceal ""))
((atx_h3_marker) @conceal (#set! conceal ""))
((atx_h4_marker) @conceal (#set! conceal ""))
((atx_h5_marker) @conceal (#set! conceal ""))
((atx_h6_marker) @conceal (#set! conceal ""))
