let s:Job = vital#grea#import('System.Job')
let s:Promise = vital#grea#import('Async.Promise')

function! grea#process#start(args, ...) abort
  let options = extend({
        \ 'cwd': getcwd(),
        \}, a:0 ? a:1 : {},
        \)
  let ns = {}
  let p = s:Promise.new(funcref('s:executor', [a:args, options, ns]))
  let p.job = ns.job
  let p.args = a:args
  return p
endfunction

function! s:executor(args, options, ns, resolve, reject) abort
  let ns = {
        \ 'stdout': [''],
        \ 'stderr': [''],
        \ 'resolve': a:resolve,
        \ 'reject': a:reject,
        \}
  let a:ns.job = s:Job.start(a:args, {
        \ 'cwd': a:options.cwd,
        \ 'on_stdout': funcref('s:on_receive', [ns.stdout]),
        \ 'on_stderr': funcref('s:on_receive', [ns.stderr]),
        \ 'on_exit': funcref('s:on_exit', [ns]),
        \})
  call grea#message#debug('%s', a:args)
endfunction

function! s:on_receive(buffer, data) abort
  let a:buffer[-1] .= a:data[0]
  call extend(a:buffer, a:data[1:])
endfunction

function! s:on_exit(ns, exitval) abort
  let data = {
        \ 'exitval': a:exitval,
        \ 'stdout': a:ns.stdout,
        \ 'stderr': a:ns.stderr,
        \}
  if a:exitval
    call a:ns.reject(data)
  else
    call a:ns.resolve(data)
  endif
endfunction
