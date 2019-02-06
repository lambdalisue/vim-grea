function! grea#message#printf(message, ...) abort
  echomsg '[grea] ' . (a:0 ? call('printf', [a:message] + a:000) : a:message)
endfunction

function! grea#message#debug(...) abort
  if &verbose
    echohl Comment
    call call('grea#message#printf', a:000)
    echohl None
  endif
endfunction

function! grea#message#warn(...) abort
  echohl WarningMsg
  call call('grea#message#printf', a:000)
  echohl None
endfunction

function! grea#message#error(...) abort
  echohl ErrorMsg
  call call('grea#message#printf', a:000)
  echohl None
endfunction
