if exists('g:loaded_grea')
  finish
endif
let g:loaded_grea = 1

command! -bang -nargs=* Grea call grea#grep(<q-bang>, <q-args>)
command! -bang -nargs=* Greal call grea#lgrep(<q-bang>, <q-args>)
command! -bang -nargs=* GreaAdd call grea#grepadd(<q-bang>, <q-args>)
command! -bang -nargs=* GrealAdd call grea#lgrepadd(<q-bang>, <q-args>)
