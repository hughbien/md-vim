Summary
=======

Syntax and keyboard shortcuts for editing Markdown files.

Install
=======
    
1. cp md-script.vim ~/.vim/scripts/md.vim
2. cp md-syntax.vim ~/.vim/syntax/md.vim
3. curl -s https://raw.github.com/hughbien/mdprev/HEAD/mdprev.rb > ~/somewhere/in/path/mdprev

To activate the syntax and script on *.md files:

    au BufNewFile,BufRead *.md set ft=md
    au Filetype md source ~/.vim/scripts/md.vim

The `mdprev` script may need to be configured.  By default, it uses the `open`
command to open HTML files:

    OPEN_HTML = 'open'

Shortcuts
=========

* `q=` turns current line into h1
* `q-` turns current line into h2
* `ql` re-numbers ordered lists
* `qz` folds current file according to headers
* `qp` preview in browser
* `qP` preview as PDF

License
=======

Copyright 2011 Hugh Bien, http://hughbien.com.
Released under MIT License, see LICENSE.md for more info.
