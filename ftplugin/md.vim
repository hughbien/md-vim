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
  while getline(ltop) =~ "^\\s*\|"
    let ltop = ltop - 1
  endwhile

  let lbot = line(".")
  while getline(lbot) =~ "^\\s*\|"
    let lbot = lbot + 1
  endwhile

  let ltop = ltop + 1
  let lbot = lbot - 1
  if ltop >= lbot
    return
  endif

  let rawTable = map(
    \ getline(ltop, lbot),
    \ "split(substitute(substitute(" .
          \ "v:val, '^\\s\\+', '', ''), '\\s\\+$', '', ''), '|', 1)")
  if len(rawTable) == 0 || len(rawTable[0]) == 0
    return
  endif

  " Trim/expand cells to include exactly one space on both sides
  let table = []
  for rawRow in rawTable
    let row = []
    for cell in rawRow
      call add(row, substitute(substitute(
        \ cell, "^\\s\*", " ", ""), "\\s\*$", " ", ""))
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

  " Add whitespace/hyphens to shorter cells, create whitespace cells as needed
  for colIndex in range(len(table))
    let row = table[colIndex]
    for i in range(len(maxlength))
      if i >= len(row)
        call add(row, "")
      endif
      if len(row[i]) < maxlength[i]
        let spaceCount = maxlength[i] - len(row[i])
        if strlen(matchstr(row[i], "^\\s*[-:]\\+\\s*$")) > 0 " is this a delimiter cell?
          let row[i] = row[i][:1] . repeat("-", spaceCount) . row[i][2:]
        else
          " find closest delimiter cell to get alignment
          let delRow = colIndex
          let align = "left"
          while delRow >= 0
            let delCell = table[delRow][i]
            if strlen(matchstr(delCell, "^\\s*[-:]\\+\\s*$")) > 0
              if strlen(matchstr(delCell, "^\\s*:")) > 0 && strlen(matchstr(delCell, ":\\s*$")) > 0
                let align = "center"
                break
              elseif strlen(matchstr(delCell, ":\\s*$")) > 0
                let align = "right"
                break
              endif
            endif
            let delRow = delRow - 1
          endwhile
          if align == "left"
            let row[i] = row[i] . repeat(" ", spaceCount)
          elseif align == "right"
            let row[i] = repeat(" ", spaceCount) . row[i]
          else
            let leftSpace = repeat(" ", float2nr(floor(spaceCount/2.0)))
            let rightSpace = repeat(" ", float2nr(ceil(spaceCount/2.0)))
            let row[i] = leftSpace . row[i] . rightSpace
          endif
        endif
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
        \ "| |", "|", "g"))
    endif
    let i = i + 1
  endwhile
endfunction

function! MdToggleTask()
  echo ""
  let row = line(".")
  let line = getline(row)
  if line =~ "\\[ \\]"
    call setline(row, substitute(line, "\\[ \\]", "[x]", ""))
  elseif line =~ "\\[x\\]"
    call setline(row, substitute(line, "\\[x\\]", "[ ]", ""))
  endif
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

function! md#setup(leader)
  exe "nmap <buffer> " . a:leader . "= :call MdMakeH1()<CR>"
  exe "nmap <buffer> " . a:leader . "- :call MdMakeH2()<CR>"
  exe "nmap <buffer> " . a:leader . "l :call MdFixOrderedList()<CR>"
  exe "nmap <buffer> " . a:leader . "x :call MdToggleTask()<CR>"
  exe "nmap <buffer> " . a:leader . "t :call MdFixTable()<CR>"
  exe "nmap <buffer> " . a:leader . "z :call MdFold()<CR>"
  exe "nmap <buffer> " . a:leader . "p :!mdprev %<CR><CR>"
  exe "nmap <buffer> " . a:leader . "P :!mdprev --pdf %<CR><CR>"
endfunction
