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
  " Delimiters are also trimmed to be as long as necessary, but no longer
  let table = []
  for rawRow in rawTable
    let row = []
    for cell in rawRow
      let trimmedCell = cell
      if strlen(matchstr(trimmedCell, "^\\s*[-:]\\{2,}\\s*$")) > 0 " is this a delimiter cell?
        let trimmedCell = substitute(trimmedCell, "--\*", "--", "") " trim extra dashes
      endif
      let trimmedCell = substitute(trimmedCell, "^\\s\*", " ", "") " trim leading whitespace
      let trimmedCell = substitute(trimmedCell, "\\s\*$", " ", "") " trim trailing whitespace
      call add(row, trimmedCell)
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
        " ^\\s*:\\?-\\{3,}:\\?\\s*$ for minimum 3 dashes
        if strlen(matchstr(row[i], "^\\s*[-:]\\{2,}\\s*$")) > 0 " is this a delimiter cell?
          let row[i] = row[i][:1] . repeat("-", spaceCount) . row[i][2:]
        else
          " find closest delimiter cell to get alignment
          let delRow = colIndex
          if delRow + 1 < len(table)
            let delRow = delRow + 1 " also include on row below, in case this is a header
          endif

          let align = "left"
          while delRow >= 0 " keep searching one cell up until delimiter is found
            let delCell = table[delRow][i]
            if strlen(matchstr(delCell, "^\\s*[-:]\\{2,}\\s*$")) > 0
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
  if a:lnum == 1 && (line =~ "^---\s*$" || line =~ "^+++\s*$")
    return '>1'
  elseif nextline =~ "^=\\+\\s*$"
    return '>1'
  elseif nextline =~ "^-\\+\\s*$"
    if getline(1) =~ "^---\s*$" " is this frontmatter yaml ending?
      let i = a:lnum - 1
      while i > 1
        if getline(i) =~ "^---\s*$"
          return '>2'
        endif
        let i = i - 1
      endwhile
    endif
    return '1' " this is frontmatter yaml ending line
  elseif line =~ "^#"
    return '>' . strlen(matchstr(line, "^#*"))
  else
    let i = a:lnum
    while i > 0
      let line = getline(i)
      let nextline = getline(i + 1)
      if i == 1 && (line =~ "^---\s*$" || line =~ "^+++\s*$")
        return '1'
      elseif nextline =~ "^=\\+\\s*$"
        return '1'
      elseif nextline =~ "^-\\+\\s*$"
        if getline(1) =~ "^---\s*$" " is this frontmatter yaml ending?
          let prev = i - 1
          while prev > 1
            if getline(prev) =~ "^---\s*$"
              return '2'
            endif
            let prev = prev - 1
          endwhile
        endif
        return '1'
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
  exe "nmap <buffer> " . a:leader . "p :!mark %<CR><CR>"
endfunction
