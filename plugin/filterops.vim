" filterops.vim
" Easy text filter operators
"
" Author: Jo Totland
" Version: 1.0

if exists("g:loaded_filterops")
    finish
endif
let g:loaded_filterops = 1

function! s:esc(str)
    return escape(a:str, '\"')
endfunction

function! s:FilterMap(opmap, linemap, vmap, filter)
    execute "nnoremap <silent> " . a:opmap . " " .
        \ ":<c-u>let g:FILTEROPS_FILTER=" . a:filter . "<cr>" .
        \ ":set operatorfunc=filterops#Filter<cr>g@"
    execute 'nnoremap <silent> <expr> ' . a:linemap .
        \ ' ":\<c-u>let g:FILTEROPS_FILTER=' .
        \ s:esc(a:filter) . '\<cr>:set operatorfunc=filterops#Filter\<cr>g@" .
        \ (v:count ? string(v:count) : "") . "_"'
    execute "vnoremap <silent> " . a:vmap . " " .
        \ ":<c-u>let g:FILTEROPS_FILTER=" . a:filter . "<cr>" .
        \ ":<c-u>call filterops#Filter(visualmode())<cr>"
endfunction

command! -nargs=* FilterMap call s:FilterMap(<f-args>)

FilterMap
    \ <plug>(yank-to-visible-terminals)
    \ <plug>(yank-line-to-visible-terminals)
    \ <plug>(yank-to-visible-terminals)
    \ function("filterops#YankToVisibleTerminals")  
command! -nargs=* YT call filterops#YankToVisibleTerminals([<q-args>])

FilterMap
    \ <plug>(yank-vimscript)
    \ <plug>(yank-vimscript-line)
    \ <plug>(yank-vimscript)
    \ function("filterops#EvalVimScriptLines")

FilterMap
    \ <plug>(filter)
    \ <plug>(filter-line)
    \ <plug>(filter)
    \ function("filterops#FilterThroughCommand")

if !exists("g:filterops_no_default_maps")
    nmap yt <plug>(yank-to-visible-terminals)
    nmap ytt <plug>(yank-line-to-visible-terminals)
    vmap gyt <plug>(yank-to-visible-terminals)

    nmap yv <plug>(yank-vimscript)
    nmap yvv <plug>(yank-vimscript-line)
    vmap gyv <plug>(yank-vimscript)

    nmap ! <plug>(filter)
    nmap !! <plug>(filter-line)
    vmap ! <plug>(filter)
endif
