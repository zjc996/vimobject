" Take <tab> for word complete only
" The 'complete' option controls where the keywords are searched (include files, tag files, buffers, and more).
" The 'completeopt' option controls how the completion occurs (for example, whether a menu is shown).

if exists('did_completes_me_loaded') || v:version < 700
  finish
endif
let did_completes_me_loaded = 1

function! s:completes_me(shift_tab)
  let dirs = ["\<c-p>", "\<c-n>"]

  if pumvisible()
    if a:shift_tab
      return dirs[0]
    else
      return dirs[1]
    endif
  endif

  " Figure out whether we should indent.
  let pos = getpos('.')
  let substr = matchstr(strpart(getline(pos[1]), 0, pos[2]-1), "[^ \t]*$")
  if strlen(substr) == 0 | return "\<Tab>" | endif

  if a:shift_tab
    return "\<c-p>"
  else
    return "\<c-n>"
  endif
endfunction

inoremap <expr> <plug>completes_me_forward  <sid>completes_me(0)
inoremap <expr> <plug>completes_me_backward <sid>completes_me(1)

imap <Tab>   <plug>completes_me_forward
imap <S-Tab> <plug>completes_me_backward
