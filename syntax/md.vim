" Language: Markdown
" Maintainer: Hugh Bien (http://hughbien.com)

if exists("b:current_syntax")
  finish
endif
syntax clear

syn match mdCode            "`[^`]\+`"
syn match mdBold            "\*\*[^\*]\+\*\*"
syn match mdBold            "\*[^\*]\+\*"
syn match mdBold            "_[^_]\+_"
syn match mdBold            "__[^_]\+__"
syn match mdLink            "[a-zA-Z]\+://[^ )]\+"
syn match mdLink            "([a-zA-Z]\+://[^ ]\+)"
syn match mdLink            "<[a-zA-Z]\+://[^ >]\+>"
syn match mdLinkText        "\[[^]]*\]"
syn match mdLinkText        "!\[[^]]*\]"
syn match mdHeader          /^.\+\n=\+\s*$/ contains=mdCode,mdBold,mdLink,mdLinkText
syn match mdHeader2         /^.\+\n-\+\s*$/ contains=mdCode,mdBold,mdLink,mdLinkText
syn match mdHeader          "^\#.*" contains=mdCode,mdBold,mdLink,mdLinkText
syn match mdHeader2         "^\##.*" contains=mdCode,mdBold,mdLink,mdLinkText
syn match mdHeader3         "^\###.*" contains=mdCode,mdBold,mdLink,mdLinkText
syn match mdHeader4         "^\####.*" contains=mdCode,mdBold,mdLink,mdLinkText
syn match mdHeader5         "^\#####.*" contains=mdCode,mdBold,mdLink,mdLinkText
syn match mdHeader6         "^\######.*" contains=mdCode,mdBold,mdLink,mdLinkText
syn match mdListItem        "^\s*\(+\|-\|*\)\s"
syn match mdNumListItem     "^\s*[0-9]\+\.\s"
syn match mdSeparator       "^===\+\s*$"
syn match mdSeparator       "^---\+\s*$"
syn match mdSeparator       "^\*\*\*\+\s*$"
syn match mdPreCode         "^    .*"
syn match mdBlockquote      "^\s*>.*"

hi def link mdCode          Constant
hi def link mdBold          Identifier
hi def link mdLink          Underlined
hi def link mdLinkText      Statement
hi def link mdHeader        Identifier
hi def link mdHeader2       Type
hi def link mdHeader3       PreProc
hi def link mdHeader4       Statement
hi def link mdHeader5       Constant
hi def link mdHeader6       Label
hi def link mdTask          Label
hi def link mdTaskDone      Ignore
hi def link mdTableBorder   Label
hi def link mdTableCell     Label
hi def link mdListItem      Label
hi def link mdNumListItem   Label
hi def link mdSeparator     String
hi def link mdPreCode       Constant
hi def link mdBlockquote    Constant

let b:current_syntax = "md"
