 " plugin for production file header for new file
 " depend on file's extension.
 " by xuriwuyun
 "
func! s:Create_hearder()
    let filename=@%
    let date=strftime("%m/%d/%Y")
    let time=strftime("%H:%M:%S")
    let hearder = [' vim: tabstop=4 shiftwidth=4 softtabstop=4',
                \'',
                \' Copyright ' . strftime("%Y") .' www.jd.com',
                \'',
                \' File: ' . filename,
                \' Author: xuriwuyun <xuriwuyun@gmail.com>',
                \' Created: '.date.' '.time,
                \' Last_modified: '.date.' '.time]

    return hearder
endfunc

"deffierent language has deffierent commentor
func! s:Add_hearder()
    " script valable will be keeped in memory, so we need to reinitiate
    " s:commentor every time when call Add_hearder
    let s:commentor='#'
    let file_type= expand("%:e")
    if file_type=='py'
        exe 'normal I'. s:commentor.'!/usr/bin/env python'
        exe "normal o". s:commentor. "\<CR>"
    elseif file_type=='sh'
        exe 'normal I'.s:commentor.'!/usr/bin/env bash'
        exe "normal o". s:commentor. "\<CR>"
    elseif or(file_type=='c', file_type=='cpp')
        let s:commentor='//'
    elseif file_type=='vim'
        let s:commentor='"'
    elseif file_type=='el'
        let s:commentor=';'
    endif

    let hearder=s:Create_hearder()
    set paste
    for line in hearder
        exe 'normal I'.s:commentor.line
        exe 'normal o'
    endfor

    "insert two blank line between hearder and body
    exe "normal o\<CR>"
    set nopaste
    startinsert
endfunc


func! s:Update_modified_time()
    let date=strftime("%m\\/%d\\/%Y")
    let time=strftime("%H:%M:%S")
    exe 'normal mp'
    try
        silent exe '1,12s/^\(.. *\)\(Last_modified: \).*/\1\2'.date.' '.time
    catch
        :
    endtry
    exe 'normal `p'

endfunc


autocmd! BufNewFile * call s:Add_hearder()
autocmd! BufWrite * call s:Update_modified_time()
