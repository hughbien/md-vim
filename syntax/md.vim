" Language: Markdown
" Maintainer: Hugh Bien (http://hughbien.com)

if exists("b:current_syntax")
  finish
endif
syntax clear

if !exists("main_syntax")
  let main_syntax = "md"
endif

syn match mdCode           "`[^`]\+`"
syn match mdItalic         "\*[^\*]\+\*"
syn match mdItalic         "_[^_]\+_"
syn match mdBold           "\*\*[^\*]\+\*\*"
syn match mdBold           "__[^_]\+__"
syn match mdStrike         "\~\~[^~]\+\~\~"
syn match mdFootnote       "\[\^[^\]]*\]"
syn match mdHtmlAttr       "\s[^>"]\+" contained
syn match mdHtmlString     "\"[^"]\+\"" contained
syn match mdHtmlTag        "<[!/]\?[^>]\+>" contains=mdHtmlAttr,mdHtmlString
syn match mdHtmlComment    "<!--.*-->"
syn match mdUrl            "<[a-zA-Z]\+://[^>]\+>"
syn match mdUrl            "</[^>/]\+[/_-][^>]*>"
syn match mdUrl            "<#[^>]*>"
syn match mdLinkUrl        "([^)]\+)" contained
syn match mdLink           "\[[^]]*\]([^)]\+)" contains=mdLinkUrl
syn match mdImg            "!\[[^]]*\]([^)]\+)" contains=mdLinkUrl
syn match mdHeaderId       /{#[^}]\+}/ contained
syn match mdHeader         /^.\+\n=\+\s*$/ contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader2        /^.\+\n-\+\s*$/ contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader         "^\#.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader2        "^\##.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader3        "^\###.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader4        "^\####.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader5        "^\#####.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdHeader6        "^\######.*" contains=mdHeaderId,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdTask           "\s*\[ \]"
syn match mdTaskDone       "\s*\[x\].*$"
syn match mdListItem       "^\s*\(+\|-\|*\)\s"
syn match mdNumListItem    "^\s*[0-9]\+\.\s"
syn match mdTableBorder    "^\s*|" contained
syn match mdTableBorder    "\s|" contained
syn match mdTableBorder    "\s|\s*$" contained
syn match mdTableRow       "^\s*|.*|\s*$" contains=mdTableBorder,mdCode,mdItalic,mdBold,mdStrike,mdLink,mdUrl,mdImg
syn match mdTableHead      "^\s*|[-: |]*|\s*$"
syn match mdSeparator      "^===\+\s*$"
syn match mdSeparator      "^---\+\s*$"
syn match mdSeparator      "^\*\*\*\+\s*$"
syn match mdBlockquote     "^\s*>.*"
syn match mdPreCode        "^    .*"
syn region mdPreCode       start="^\s*````*.*$" end="^\s*````*\ze\s*$" keepend
syn region mdPreCode       start=/\%^+++\s*$/ end=/^+++\s*$/ keepend

" fenced implementation copied from https://github.com/tpope/vim-markdown
if !exists("g:md_fenced_languages")
  let g:md_fenced_languages = []
endif
let s:done_include = {}
for s:type in map(copy(g:md_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if has_key(s:done_include, matchstr(s:type,'[^.]*'))
    continue
  endif
  if s:type =~ '\.'
    let b:{matchstr(s:type,'[^.]*')}_subtype = matchstr(s:type,'\.\zs.*')
  endif
  exe 'syn include @markdownHighlight'.substitute(s:type,'\.','','g').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  unlet! b:current_syntax
  let s:done_include[matchstr(s:type,'[^.]*')] = 1
endfor
unlet! s:type
unlet! s:done_include

if main_syntax ==# "md"
  let s:concealends = ""
  let s:done_include = {}
  for s:type in g:md_fenced_languages
    if has_key(s:done_include, matchstr(s:type,'[^.]*'))
      continue
    endif
    exe 'syn region markdownHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\..*','','').' matchgroup=mdPreCode start="^\s*````*\s*\%({.\{-}\.\)\='.matchstr(s:type,'[^=]*').'}\=\S\@!.*$" end="^\s*````*\ze\s*$" keepend contains=@markdownHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\.','','g') . s:concealends
    let s:done_include[matchstr(s:type,'[^.]*')] = 1
  endfor
  unlet! s:type
  unlet! s:done_include
endif

" Options: Comment String Number Keyword PreProc Conditional Todo Constant
" Identifier Function Type Statement Special Delimiter Operator Error
hi def link mdCode           PreProc
hi def link mdItalic         Function
hi def link mdBold           Number
hi def link mdStrike         Comment
hi def link mdFootnote       String
hi def link mdHtmlComment    Comment
hi def link mdHtmlAttr       Number
hi def link mdHtmlString     String
hi def link mdHtmlTag        Identifier
hi def link mdUrl            Underlined
hi def link mdLinkUrl        Underlined
hi def link mdLink           String
hi def link mdImg            String
hi def link mdHeaderId       Keyword
hi def link mdHeader         Identifier
hi def link mdHeader2        Type
hi def link mdHeader3        Function
hi def link mdHeader4        Number
hi def link mdHeader5        Keyword
hi def link mdHeader6        String
hi def link mdTask           Constant
hi def link mdTaskDone       Comment
hi def link mdListItem       Label
hi def link mdNumListItem    Label
hi def link mdTableHead      Comment
hi def link mdTableBorder    Comment
hi def link mdSeparator      Comment
hi def link mdBlockquote     Number
hi def link mdPreCode        PreProc

let b:current_syntax = "md"
if main_syntax ==# "md"
  unlet main_syntax
endif

" Front-Matter YAML
unlet b:current_syntax
syn include @mdYaml syntax/yaml.vim
syn region mdFrontYaml start=/\%^---\s*$/ end=/^---\s*$/ keepend contains=@mdYaml
