# Summary

Keyboard shortcuts for editing Markdown files.

# Install
    
If you're using [pathogen](https://github.com/tpope/vim-pathogen), drop this
project under `~/.vim/bundle`.  Otherwise, you'll need to copy a file:

    $ cp ftplugin/markdown.vim ~/.vim/ftplugin/markdown.vim

For preview support:

    sudo gem install mdprev

To automatically set filetype and load the plugin:

    filetype plugin on  " if you don't already have it
    au BufNewFile,BufRead *.md set ft=markdown

# Shortcuts

* `q=` turns current line into h1
* `q-` turns current line into h2
* `ql` re-numbers ordered lists
* `qt` formats a table
* `qz` folds current file according to headers
* `qp` preview in browser
* `qP` preview as PDF

# License

Copyright Hugh Bien, http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
