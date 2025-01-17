"
" ~/.vim/ftplugin/perl/init.vim
" ---
" noremap K :Perldoc<CR>
" ---
"

if exists("g:loaded_perldoc")
  finish
endif
let g:loaded_perldoc = 1

let s:buf_nr = -1
let s:mode = ''
let s:last_word = ''
let b:window_vsplit = 0

function! s:PerldocView()
  " base on FuzzyFinder WindowManager
  let cwd = getcwd()

  if !bufexists(s:buf_nr)
    if b:window_vsplit
      rightbelow vnew
    else
      leftabove new
    end
    file \[Perldoc]
    let s:buf_nr = bufnr('%')
  elseif bufwinnr(s:buf_nr) == -1
    if b:window_vsplit
      rightbelow vnew
    else
      leftabove new
    end
    execute s:buf_nr . 'buffer'
    delete _
  elseif bufwinnr(s:buf_nr) != bufwinnr('%')
    execute bufwinnr(s:buf_nr) . 'wincmd w'
  endif

  " countermeasure for auto-cd script
  execute ':lcd ' . cwd
  setlocal filetype=man
  setlocal bufhidden=delete
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nobuflisted
  setlocal modifiable
  setlocal nocursorline
  setlocal nocursorcolumn
  setlocal iskeyword+=:
  setlocal iskeyword-=-

  call s:SetKeyMaps()

  au BufHidden <buffer> call let <SID>buf_nr = -1
endfunction

function! s:SetKeyMaps()
  noremap <buffer> <silent> K :Perldoc<CR>
  noremap <buffer> <silent> s :call <SID>Toggle()<CR>
endfunction

function! s:PerldocWord(word)
  if s:ClassExist(a:word)
    let s:mode = ''
    let s:last_word = a:word
    call s:ShowCmd('0read!perldoc -otext -T ' . a:word)
    setfiletype man
  elseif s:FuncExist(a:word)
    let s:mode = ''
    let s:last_word = a:word
    call s:ShowCmd('0read!perldoc -otext -f ' . a:word)
    setfiletype man
  else
    echo 'No documentation found for "' . a:word . '".'
  end
endfunction

function! s:PerldocSource(word)
  if s:ClassExist(a:word)
    let s:mode = 'source'
    call s:ShowCmd('0read!perldoc -m ' . a:word)
    setfiletype perl
  end
endfunction

function! s:Toggle()
  if s:mode == 'source'
    call s:PerldocWord(s:last_word)
  else
    call s:PerldocSource(s:last_word)
  end
endfunction

function! s:ShowCmd(cmd)
  call s:PerldocView()
  setlocal modifiable
  normal ggdG
  silent execute a:cmd
  normal gg
  setlocal nomodifiable
endfunction

function! s:ClassExist(word)
  silent call system('perldoc -otext -T ' . a:word)
  if v:shell_error
    return 0
  else
    return 1
  endif
endfunction

function! s:FuncExist(word)
  silent call system('perldoc -otext -f ' . a:word)
  if v:shell_error
    return 0
  else
    return 1
  endif
endfunction

function! s:Perldoc(...)
  let word = join(a:000, ' ')
  if !strlen(word)
    let word = expand('<cword>')
  endif
  call s:PerldocWord(word)
endfunction

command! -nargs=* -complete=file Perldoc :call s:Perldoc(<q-args>)
"command! -nargs=* -bang -complete=customlist,s:RefeComplete Refe :call s:RefeExec(<bang>0,<f-args>)
