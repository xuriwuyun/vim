" plugin for production file header for new file
" depend on file's extension.
" by xuriwuyun
"

func! s:Create_header()
    let filename=@%
    let date=strftime("%m/%d/%Y")
    let time=strftime("%H:%M:%S")
    let header = [' vim: tabstop=4 shiftwidth=4 softtabstop=4',
                \'',
                \' Copyright ' . strftime("%Y") .' www.alibaba-inc.com',
                \'',
                \' File: ' . filename,
                \' Author: xuriwuyun <xuriwuyun@gmail.com>',
                \' Created: '.date.' '.time,
                \' Last_modified: '.date.' '.time]

    return header
endfunc

" deffierent language has deffierent commentor
func! s:Add_header()
    " script valable will be keeped in memory, so we need to reinitiate
    " s:commentor every time when call Add_header
    " let s:commentor='#'
    " let file_type= expand("%:e")
    " if file_type=='py'
    "     exe 'normal I'. s:commentor.'!/usr/bin/env python'
    "     exe "normal o". s:commentor. "\<CR>"
    " elseif file_type=='sh'
    "     exe 'normal I'.s:commentor.'!/usr/bin/env bash'
    "     exe "normal o". s:commentor. "\<CR>"
    " elseif file_type=='c' || file_type=='cpp' || file_type=='go'
    "     let s:commentor='//'
    " elseif file_type=='vim'
    "     let s:commentor='"'
    " elseif file_type=='el'
    "     let s:commentor=';'
    " endif

    let commentsdict = s:Commentsdict()
    if has_key(commentsdict, 's')
        let l:header = s:header_with_three_piece_comment(commentsdict)
    else 
        let l:header = s:header_with_normal_comment(commentsdict)
    endif

    if len(l:header) > 0
        set paste
        "insert two blank line between header and body
        let l:header = l:header + ["", ""]
        call append(0, l:header)
        set nopaste
    endif

    call cursor(line('$'), col('$'))
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

func! s:header_with_three_piece_comment(commentsdict)
    let l:header = s:Create_header()
    let l:header_with_comments = []
    let l:i = 1
    for line in header
        if l:i == 1
            let l:line_with_comment = a:commentsdict['s'].' '.line
        else
            let l:line_with_comment = ' '.a:commentsdict['m'].' '.line
        endif
        call add(l:header_with_comments, l:line_with_comment)
        let l:i = l:i + 1
    endfor
    call add(l:header_with_comments,  ' '.a:commentsdict['e'])
    return l:header_with_comments
endfunc

func! s:header_with_normal_comment(commentsdict)
    let l:header = s:Create_header()
    let l:header_with_comments = []
    if has_key(a:commentsdict, 'b')
        let l:commentor = a:commentsdict['b']
    elseif has_key(a:commentsdict, '')
        let l:commentor = a:commentsdict['']
    else 
        return l:header_with_comments
    endif

    for line in header
        let l:line_with_comment = l:commentor.' '.line
        call add(l:header_with_comments, l:line_with_comment)
    endfor
    return l:header_with_comments

endfunc

func! s:Commentsdict()
    let l:commentstring = &comments
    let l:comments = split(l:commentstring, ',')
    let l:commentsdict = {}
    for comment in l:comments
        let kv = split(comment, ':', 1) 
        let key = kv[0]
        if key =~ '^s'
            let l:commentsdict['s'] = kv[1]
        elseif key =~ '^m'
            let l:commentsdict['m'] = kv[1]
        elseif key =~ '^e'
            let l:commentsdict['e'] = kv[1]
        elseif key =~ '^b'
            let l:commentsdict['b'] = kv[1]
        else
            let l:commentsdict[kv[0]] = kv[1]
        endif
    endfor
    return l:commentsdict
endfunc

autocmd! BufNewFile * call s:Add_header()
autocmd! BufWrite * call s:Update_modified_time()
