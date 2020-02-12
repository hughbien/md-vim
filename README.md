# Summary

Syntax and keyboard shortcuts for editing Markdown files.

# Install

If you're using [vim-plug](https://github.com/junegunn/vim-plug), add this
line to your `~/.vimrc` plugin section:

    Plug 'hughbien/md-vim'

If you're using [Vundle](https://github.com/VundleVim/Vundle.vim), add this
line to your `~/.vimrc` plugin section:

    Plugin 'hughbien/md-vim'
    
If you're using [Pathogen](https://github.com/tpope/vim-pathogen), drop this
project under `~/.vim/bundle`.

Otherwise, you'll need to copy two files:

    $ cp ftplugin/md.vim ~/.vim/ftplugin/md.vim
    $ cp syntax/md.vim ~/.vim/syntax/md.vim

For preview support:

    sudo gem install mdprev

To automatically set filetype and load the plugin:

    filetype plugin on                     " if you don't already have it
    au bufnewfile,bufread *.md set ft=md
    au bufreadpost *.md call md#setup("q") " where q is your leader key

# Shortcuts

* `<leader>=` turns current line into h1
* `<leader>-` turns current line into h2
* `<leader>l` re-numbers ordered lists
* `<leader>x` toggles a task line
* `<leader>t` formats a table
* `<leader>z` folds current file according to headers
* `<leader>p` preview in browser
* `<leader>P` preview as PDF

# License

Copyright Hugh Bien, http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
