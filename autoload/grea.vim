let s:processes = []

function! grea#processes() abort
  return s:processes
endfunction

function! grea#grep(bang, args) abort
  doautocmd <nomodeline> QuickFixCmdPre grep
  call s:grep('cfile' . a:bang, a:args)
        \.then({ -> execute('doautocmd <nomodeline> QuickFixCmdPost grep') })
endfunction

function! grea#lgrep(bang, args) abort
  doautocmd <nomodeline> QuickFixCmdPre lgrep
  call s:grep('lfile' . a:bang, a:args)
        \.then({ -> execute('doautocmd <nomodeline> QuickFixCmdPost lgrep') })
endfunction

function! grea#grepadd(bang, args) abort
  doautocmd <nomodeline> QuickFixCmdPre grepadd
  call s:grep('caddfile' . a:bang, a:args)
        \.then({ -> execute('doautocmd <nomodeline> QuickFixCmdPost grepadd') })
endfunction

function! grea#lgrepadd(name, bang, args) abort
  doautocmd <nomodeline> QuickFixCmdPre lgrepadd
  call s:grep('laddfile' . a:bang, a:args)
        \.then({ -> execute('doautocmd <nomodeline> QuickFixCmdPost lgrepadd') })
endfunction

function! s:grep(cmd, cmdline) abort
  let tempfile = s:makeef()
  let cmdline = join([
        \ s:grepprg(),
        \ a:cmdline,
        \ &shellpipe,
        \ shellescape(tempfile),
        \])
  let args = [&shell, &shellcmdflag, cmdline]
  let proc = grea#process#start(args)
        \.then(funcref('s:on_then', [a:cmd, tempfile]))
        \.catch(funcref('s:on_catch'))
  call add(s:processes, proc)
  return proc.finally(funcref('s:on_finally', [proc]))
endfunction

function! s:on_then(cmd, tempfile, data) abort
  execute join([a:cmd, fnameescape(a:tempfile)])
endfunction

function! s:on_catch(data) abort
  call grea#message#error(a:data.stderr)
  call grea#message#debug(a:data.stdout)
endfunction

function! s:on_finally(proc) abort
  let index = index(s:processes, a:proc)
  if index isnot# -1
    call remove(s:processes, index)
  endif
endfunction

function! s:grepprg() abort
  return join(map(split(&grepprg), { -> expand(v:val) }))
endfunction

function! s:makeef() abort
  return empty(&makeef)
        \ ? tempname()
        \ : expand(substitute(&makeef, '##', sha256(string(localtime())), 'g'))
endfunction

augroup grea_internal
  autocmd! *
  autocmd QuickFixCmdPre * :
  autocmd QuickFixCmdPost * :
augroup END
