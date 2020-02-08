function! MdMakeH1()
  echo ""
  call MdMakeHeader("=")
endfunction

function! MdMakeH2()
  echo ""
  call MdMakeHeader("-")
endfunction

function! MdMakeHeader(character)
  let line = substitute(getline("."), "\\s\\+$", "", "")
  let nextline = getline(line(".") + 1)
  let border = substitute(line, ".", a:character, "g")
  call setline(".", line)
  if nextline =~ "^" . a:character . "\\+\\s*$"
    call setline(line(".") + 1, border)
  else
    call append(".", border)
  endif
endfunction

function! MdFixOrderedList()
  echo ""
  let ltop = line(".")
  while getline(ltop) =~ "^\\s*[0-9]\\+\\." ||
      \ (getline(ltop) =~ "^\\s" && getline(ltop) !~ "^\\s*$")
    let ltop = ltop - 1
  endwhile

  let lbot = line(".")
  while getline(lbot) =~ "^\\s*[0-9]\\+\\." ||
      \ (getline(lbot) =~ "^\\s" && getline(lbot) !~ "^\\s*$")
    let lbot = lbot + 1
  endwhile

  let ltop = ltop + 1
  let lbot = lbot - 1
  if ltop > lbot
    return
  endif

  let i = 1
  let row = ltop
  while row <= lbot
    let line = getline(row)
    if line =~ "^\\s*[0-9]\\+\\."
      call setline(row, substitute(line, "[0-9]\\+", i, ""))
      let i = i + 1
    endif
    let row = row + 1
  endwhile
endfunction

function! MdFixTable()
  echo ""
  let ltop = line(".")
  while getline(ltop) =~ "^\\s*\+\[\+\-\]*$" ||
      \ getline(ltop) =~ "^\\s*\|"
    let ltop = ltop - 1
  endwhile

  let lbot = line(".")
  while getline(lbot) =~ "^\\s*\+\[\+\-\]*$" ||
      \ getline(lbot) =~ "^\\s*\|"
    let lbot = lbot + 1
  endwhile

  let ltop = ltop + 1
  let lbot = lbot - 1
  if ltop >= lbot
    return
  endif

  let rawTable = map(
    \ filter(getline(ltop, lbot), "v:val !~ '^\\s*\+\[\+\-\]*$'"),
    \ "split(substitute(substitute(" .
          \ "v:val, '^\\s\\+', '', ''), '\\s\\+$', '', ''), '|', 1)")
  if len(rawTable) == 0 || len(rawTable[0]) == 0
    return
  endif

  " Trim cells to include only one space on both sides
  let table = []
  for rawRow in rawTable
    let row = []
    for cell in rawRow
      call add(row, substitute(substitute(
        \ cell, "^\\s\\+", " ", ""), "\\s\\+$", " ", ""))
    endfor
    call add(table, row)
  endfor

  " Find maxlength of each column
  let maxlength = map(copy(table[0]), "len(v:val)")
  for row in table
    for i in range(len(row))
      if i >= len(maxlength)
        call add(maxlength, 0)
      endif
      if len(row[i]) > maxlength[i]
        let maxlength[i] = len(row[i])
      endif
    endfor
  endfor

  " Add whitespace to shorter cells, create whitespace cells as needed
  for row in table
    for i in range(len(maxlength))
      if i >= len(row)
        call add(row, "")
      endif
      if len(row[i]) < maxlength[i]
        let row[i] = row[i] . repeat(" ", maxlength[i] - len(row[i]))
      endif
    endfor
  endfor

  " Regenerate the table, eliminate blank (0 length) columns as needed
  let border = substitute(
    \ "+" . join(map(copy(maxlength), "repeat('-', v:val)"), "+") . "+",
    \ "++", "+", "g")
  let i = ltop
  while i <= lbot
    if getline(i) =~ "^\\s*\+\[\+\-]*$"
      call setline(i, border)
    else
      call setline(i, substitute(
        \ "|" . join(remove(table, 0), "|") . "|",
        \ "||", "|", "g"))
    endif
    let i = i + 1
  endwhile
endfunction

function! MdFoldLevel(lnum)
  let line = getline(a:lnum)
  let nextline = getline(a:lnum + 1)
  if nextline =~ "^=\\+\\s*$"
    return '>1'
  elseif nextline =~ "^-\\+\\s*$"
    return '>2'
  elseif line =~ "^#"
    return '>' . strlen(matchstr(line, "^#*"))
  else
    let i = a:lnum
    while i > 0
      let line = getline(i)
      let nextline = getline(i + 1)
      if nextline =~ "^=\\+\\s*$"
        return '1'
      elseif nextline =~ "^-\\+\\s*$"
        return '2'
      elseif line =~ "^#"
        return strlen(matchstr(line, "^#*"))
      endif
      let i = i - 1
    endwhile
    return '0'
  endif
endfunction

function! MdFoldText()
  let line = getline(v:foldstart)
  let nextline = getline(v:foldstart + 1)
  if line !~ "^#"
    if nextline =~ "^="
      return ("# " . line)
    elseif nextline =~ "^-"
      return ("## " . line)
    endif
  endif
  return line
endfunction

function! MdFold()
  echo ""
  set foldenable
  set foldmethod=expr
  set foldexpr=MdFoldLevel(v:lnum)
  set foldtext=MdFoldText()
  set foldlevel=0
endfunction

" Shortcuts
nmap <buffer> q= :call MdMakeH1()<CR>
nmap <buffer> q- :call MdMakeH2()<CR>
nmap <buffer> ql :call MdFixOrderedList()<CR>
nmap <buffer> qt :call MdFixTable()<CR>
nmap <buffer> qz :call MdFold()<CR>
nmap <buffer> qp :!mdprev %<CR><CR>
nmap <buffer> qP :!mdprev --pdf %<CR><CR>
