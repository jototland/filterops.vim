" filterops.vim
" Easy text filter operators
"
" Author: Jo Totland
" Version 1.0

if exists("g:autoloaded_filterops")
    finish
endif
let g:autoloaded_filterops = 1

function! filterops#Filter(mode) abort
    let lines = filterops#GetLines(a:mode)
    try
        if type(g:FILTEROPS_FILTER) ==# v:t_string
            let result = s:systemlist(g:FILTEROPS_FILTER, lines)
            if len(result) > 0
                call filterops#SetLines(a:mode, result)
            else
                call s:printError("External command: " . g:FILTEROPS_FILTER . " failed!")
            endif
        elseif type(g:FILTEROPS_FILTER) ==# v:t_func
            let result = g:FILTEROPS_FILTER(lines)
            if type(result) ==# v:t_list
                call filterops#SetLines(a:mode, result)
            endif
        else
            return
        endif
    catch
        call s:printError(v:exception)
    endtry
endfunction

function! filterops#YankToVisibleTerminals(lines) abort
    let oldwin = winnr()
    let count = 0
    if type(a:lines) ==# v:t_list
        let text = join(a:lines, "\r") . "\r"
    elseif type(a:lines) ==# v:t_string
        let text = substitute(a:lines, "\n", "\r", "")
        let text = substitute(text, "[^\r]$", "\r", "")
    endif
    for win in range(1, winnr('$'))
        let buf = winbufnr(win)
        let type = getbufvar(buf, "&buftype")
        let skip = getbufvar(buf, "yank_to_visible_terminals_skip_this", 0)
        if type ==# "terminal" && !skip
            let count += 1
            if has("nvim")
                let jobid = getbufvar(buf, "terminal_job_id", 0)
                call jobsend(jobid, text)
                execute win . 'wincmd w'
                normal G
                execute oldwin . 'wincmd w'
            else
                call term_sendkeys(buf, text)
                call term_wait(buf)
            endif
        endif
    endfor
    if count ==# 0
        call s:printError("No visible terminals")
    endif
endfunction

function! filterops#EvalVimScriptLines(lines)
    let g:lines = a:lines
    try
        call execute(a:lines, '')
    finally
    endtry
endfunction

function! filterops#FilterThroughCommand(lines)
    let cmd = input('filter through which command?> ')
    let g:FILTEROPS_FILTER=cmd
    let result = s:systemlist(g:FILTEROPS_FILTER, a:lines)
    if len(result) > 0
        return result
    else
        call s:printError("External command: '" . g:FILTEROPS_FILTER . "' failed!")
    endif
endfunction

function! filterops#TitleCase(lines)
    let lines = copy(a:lines)
    call map(lines, {k,v -> substitute(v, '\<\(\w\+\)\>', '\L\u\1', 'g') })
    return lines
endfunction

function! s:systemlist(cmd, input)
    let result = systemlist(a:cmd, a:input)
    call map(result, {k, v -> substitute(v, '\r$', '', '') })
    return result
endfunction

function! filterops#GetLines(mode) abort
    let saveReg = getreg('"', 1, 1)
    let saveType = getregtype('"')
    let result = ""
    try
        if a:mode ==? 'v' || a:mode ==# "\<c-v>"
            silent normal! gvy
        elseif a:mode ==# "char"
            silent normal! `[v`]y
        elseif a:mode ==# "line"
            silent normal! `[V`]y
        elseif a:mode ==# "block"
            silent execute "normal! `[\<c-v>`]y"
        endif
    finally
        let result = getreg('"', 1, 1)
        call setreg('"', saveReg, saveType)
    endtry
    return result
endfunction

function! filterops#SetLines(mode, lines) abort
    let saveReg = getreg('"', 1, 1)
    let saveType = getregtype('"')
    call setreg('"', a:lines, a:mode[0])
    try
        if a:mode ==? "v" || a:mode ==# "\<c-v>"
            noautocmd silent normal! gvp
        elseif a:mode ==# "char"
            noautocmd silent normal! `[v`]p
        elseif a:mode ==# "line"
            noautocmd silent normal! `[V`]p
        elseif a:mode ==# "block"
            noautocmd silent execute "normal! `[\<c-v>`]p"
        endif
    finally
        call setreg('"', saveReg, saveType)
    endtry
endfunction

function! s:printError(msg) abort
    execute 'normal! \<Esc>'
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction
