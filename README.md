Summary
=======

Syntax and keyboard shortcuts for editing Markdown files.

Install
=======
    
If you're using [pathogen](https://github.com/tpope/vim-pathogen), drop this
project under `~/.vim/bundle`.  Otherwise, you'll need to copy some files:

    $ cp ftplugin/md.vim ~/.vim/ftplugin/md.vim
    $ cp syntax/md.vim ~/.vim/syntax/md.vim

For preview support:

    sudo gem install mdprev

To automatically set filetype and load the plugin:

    filetype plugin on  " if you don't already have it
    au BufNewFile,BufRead *.md set ft=md

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

Copyright Hugh Bien, http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
