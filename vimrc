" Make Vim more useful
set nocompatible

" ================================== PATHOGEN ==================================

" Pathogen load
filetype off
call pathogen#infect()
call pathogen#helptags()

" =============================== GENERAL CONFIG ===============================

set shell=bash                  " Use bash instead of sh
set backspace=indent,eol,start  " Allow backspace in insert mode
set iskeyword+=_                " Don't treat underscore as word separator
set history=1000                " Store lots of :cmdline history
set nojoinspaces                " Only insert single space after a '.', '?' and '!' with a join command
set nostartofline               " Don’t reset cursor to start of line when moving around
set virtualedit=onemore         " Allow the cursor to go one character after the end of the line
set ttyfast                     " Optimize for fast terminal connections
set encoding=utf-8 nobomb       " Use UTF-8 without BOM
set nomodeline                  " Do not use modelines, because of security vulnerability

runtime macros/matchit.vim      " Make % key smarter

" Enable mouse in all modes
if has('mouse')
  set mouse=a
endif

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

" Don't use viminfo when in diff mode, messes up cursor position
if &diff
    set viminfo="NONE"
endif

" ================================ LOOK & FEEL =================================

" Theme
set background=dark
colorscheme Tomorrow-Night-Eighties

set showcmd         " Show incomplete cmds down the bottom
set showmode        " Show current mode down the bottom
set report=0        " Show all changes
set title           " Show the filename in the window titlebar
set laststatus=2    " Always show status line
set showtabline=2   " Always show tab bar

" ================================ ERROR BELLS ================================

" Disable beep on errors
set noerrorbells
set visualbell

" ================================ LINE NUMBERS ================================

set number                      " Line numbers are good
set relativenumber              " Relative line number are even better
set numberwidth=5               " Show line numbers of up to 4 characters

" ================================= SWAP FILES =================================

set noswapfile
set nobackup
set nowritebackup

" ============================== PERSISTENT UNDO ===============================

" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================================ INDENTATION =================================

set autoindent      " Copy indent from last line when starting a new line
set smartindent     " Make indenting smarter
set smarttab        " At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shiftwidth spaces.
set expandtab       " Expand tabs to spaces
set shiftwidth=4    " The # of spaces for indenting
set softtabstop=4   " The # of spaces tab key results in
set tabstop=4       " The # of spaces tabs indent

" ================================ HIGHLIGHTING ================================

syntax on           " Turn syntax highlighting on

" Hightlight color
highlight SpecialKey ctermfg=DarkGray ctermbg=Black

" Make diff mode actually readable
if &diff
    highlight! link DiffText MatchParen
endif

" Display tabs and trailing spaces visually
set list listchars=tab:▸\ ,trail:·,eol:¬,nbsp:_

set showmatch       " Show matching brackets
set matchtime=5     " Duration to show matching brace
set cursorline      " Highlight current line

" ================================== WRAPPING ==================================

set wrap                    " Wrap lines
set linebreak               " Wrap lines at convenient points

" =================================== FOLDS ====================================

" Turn folding off for real, hopefully
set foldmethod=manual
set nofoldenable

" ================================= COMPLETION =================================

set completeopt=longest,menu,preview

set wildmode=longest:full
set wildmenu                       " Enable ctrl-n and ctrl-p to scroll thru matches
set wildignorecase                 " Use case insensitive completion
" Stuff to ignore when tab completing
set wildignore=*.o,*.obj,*.pyc,*~  " Ignore compiled files
set wildignore+=.git/*
set wildignore+=*DS_Store*

set omnifunc=syntaxcomplete#Complete

" ================================= SCROLLING ==================================

" Start scrolling when we're 5 lines away from margins vertically
set scrolloff=5
" And 15 from the sides
set sidescrolloff=15
set sidescroll=1

" =================================== SPLITS ===================================

set splitbelow          " New split goes below
set splitright          " New split goes right
set switchbuf=useopen   " Don't open a new split if the buffer is already open

" Set size of windows, always showing 79 columns vertical
" and show the most possible horizontally while keeping 5 lines of each split
set winwidth=79
silent! set winminwidth=20
set winheight=5
set winminheight=5
set winheight=999

" =================================== SEARCH ===================================

set incsearch       " Find the next match as we type the search
set hlsearch        " Highlight searches by default
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital
set gdefault        " Substitute all matches on a line

" ================================= FILETYPES ==================================

" Enable file type detection
filetype plugin on
filetype indent on

" ================================== AUTOCMD ===================================

if has("autocmd")
  " Create vimrc autocmd group and remove any existing vimrc autocmds,
  " in case .vimrc is re-sourced.
  augroup vimrc
    autocmd!
  augroup END


  " Change cursor shape appropriately
  " Block in normal, Bar in insert, Underscore in replace
  " See the C-z remap for foreground - background hack
  " http://stackoverflow.com/a/17100535
  autocmd vimrc VimEnter * silent !echo -ne "\x1b[\x32 q"
  autocmd vimrc InsertEnter *
              \ if v:insertmode == 'i' |
              \   silent execute '!echo -ne "\x1b[\x36 q"' |
              \ elseif v:insertmode == 'r' |
              \   silent execute '!echo -ne "\x1b[\x34 q"' |
              \ endif
  autocmd vimrc InsertLeave * silent !echo -ne "\x1b[\x32 q"
  autocmd vimrc VimLeave * silent !echo -ne "\x1b[\x32 q"

  " When editing a file, always jump to the last known cursor position. Don't do
  " it for commit messages, when the position is invalid, when inside an
  " event handler (happens when dropping a file on gvim) or in diff mode.
  autocmd vimrc BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") && !&diff |
    \   exe "normal g`\"" |
    \ endif

  " Regenerate tags on write
  autocmd vimrc BufWritePost *
    \ if exists('b:git_dir') && executable(b:git_dir.'/hooks/ctags') |
    \   call system('"'.b:git_dir.'/hooks/ctags" &') |
    \ endif

  " Show absolute numbers in insert mode, otherwise relative line numbers.
  autocmd vimrc InsertEnter * :setl number norelativenumber
  autocmd vimrc InsertLeave * :setl relativenumber

  " Don't expand tabs in hosts file, that's the syntax
  autocmd vimrc BufNewFile,BufRead hosts setl noexpandtab
  " Treat .json files as .js
  autocmd vimrc BufNewFile,BufRead *.json setl ft=json syn=javascript
  " Treat .md files as Markdown
  autocmd vimrc BufNewFile,BufRead *.md setl ft=markdown
  " Vagrantfile
  autocmd vimrc BufNewFile,BufRead Vagrantfile setl ft=ruby
  " Turn on syntax hightlight for editing from bash vi mode
  autocmd vimrc BufNewFile,BufRead bash-fc.* setl filetype=sh
  " Proper indentation for source files
  autocmd vimrc FileType puppet,ruby,sh,json,yaml setl ts=2 sts=2 sw=2
  " Don't start new lines w/ comment leader on pressing 'o'
  autocmd vimrc Filetype * setl fo-=o
  " Terraform
  autocmd vimrc BufNewFile,BufRead *.tfvars setl ft=tf
  " Use taskpaper for TODO files
  autocmd vimrc BufNewFile,BufRead TODO setl ft=taskpaper
  " https://github.com/nvie/vimrc/blob/master/vimrc :489
  "  augroup python_files "{{{
  "        au!
  "        " Automatic insertion of breakpoints
  "        autocmd filetype python nnoremap <Buffer> <Leader>bp :normal oimport pdb; pdb.set_trace()  # TODO: BREAKPOINT  # noqa<Esc>
  "    augroup end " }}}
endif

" ================================== MAPPINGS ==================================

" Change leader to a comma
let mapleader=","

" Override C-Z (background current process) to change back the cursor
" when brought back to foreground
noremap <C-z> :suspend<CR>:silent execute '!echo -ne "\x1b[\x32 q"'<CR>:redraw!<CR>

" Ctrl-H/J/K/L select split
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Useful mappings for managing tabs
noremap <Leader>tn :tabnew<CR>
noremap <Leader>to :tabonly<CR>
noremap <Leader>tc :tabclose<CR>
noremap <Leader>tm :tabmove
noremap <Leader>t<Leader> :tabnext<CR>

" Save a file as root
command! W w !sudo tee % > /dev/null

" Sane movement with wrap turned on
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" Return clears search highlight
nnoremap <silent> <CR> :nohlsearch<CR>

" Copy and paste using system clipboard
if has('clipboard')
    nnoremap <silent> y :silent set opfunc=YankFunction<CR>g@
    nnoremap yy "+yy
    nnoremap Y "+Y
    vnoremap y "+y
    vnoremap Y "+Y`[
    nnoremap <Leader>p "+p`]
    nnoremap <Leader>P "+P`]
    vnoremap <Leader>p "+p`]
    vnoremap <Leader>P "+P`]

    " Just to be able to jump the end of the copied text
    function! YankFunction(...)
        silent execute "normal! `[v`]\"+y`]"
    endfunction
" Copy using either native pbcopy or with ~/.bin/Linux/pbcopy hack if present
elseif executable('remote-copy') && executable('remote-paste')
    nnoremap <silent> y :silent set opfunc=YankFunction<CR>g@
    nnoremap <silent> yy yy:silent let res = system("remote-copy", @")<CR>
    nnoremap <silent> Y Y:silent let res = system("remote-copy", @")<CR>
    vnoremap <silent> y y:silent let res = system("remote-copy", @")<CR>
    vnoremap <silent> Y Y:silent let res = system("remote-copy", @")<CR>`[
    nnoremap <silent> <Leader>p :let @"=system("remote-paste")<CR>p`]
    nnoremap <silent> <Leader>P :let @"=system("remote-paste")<CR>P`]
    vnoremap <silent> <Leader>p :<CR>:let @"=system("remote-paste") \| execute "normal! vgv"<CR>p`]
    vnoremap <silent> <Leader>P :<CR>:let @"=system("remote-paste") \| execute "normal! vgv"<CR>P`]

    function! YankFunction(...)
        silent execute "normal! `[v`]y`]"
        silent let res = system("remote-copy", @")
    endfunction
endif

" Automatically jump to end of text you pasted:
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" Don't store single deleted characters in registers
noremap x "_x

" Auto center on matched string.
noremap n nzz
noremap N Nzz

" Search using normal regexes hacked with searchindex mappings
nnoremap / :ShowSearchIndex<CR>/\v
vnoremap / :ShowSearchIndex<CR>/\v

" Visually select the text that was last edited/pasted (Vimcast#26).
noremap gV `[v`]

" Speed up scrolling of the viewport slightly
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>

" Disable arrow keys
noremap <Left> :echo "no!"<CR>
noremap <Right> :echo "no!"<CR>
noremap <Up> :echo "no!"<CR>
noremap <Down> :echo "no!"<CR>

" Open files in directory of the current file
cnoremap <expr> %% expand('%:h').'/'
nmap <Leader>v :view %%
nmap <Leader>e :edit %%

" Leader leader switches between the two most recent buffers
nnoremap <Leader><Leader> <C-^>

" Indenting in visual mode should keep the highlight
vnoremap < <gv
vnoremap > >gv

" ================================= FUNCTIONS ==================================

" Hack to change preview window sizes in the same fashion
" http://stackoverflow.com/a/3787326
set previewheight=999
au BufEnter ?* call PreviewHeightWorkAround()
function! PreviewHeightWorkAround()
    if &previewwindow
        exec 'setlocal winheight='.&previewheight
    endif
endfunction

" Strip trailing whitespace
function! StripWhitespace()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction
noremap <Leader>ss :call StripWhitespace()<CR>

" Tab - Indent if we're at the beginning of a line. Else, do completion.
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<Tab>"
    else
        return "\<C-p>"
    endif
endfunction
inoremap <expr> <Tab> InsertTabWrapper()
inoremap <S-Tab> <C-n>
inoremap <C-Tab> <C-x><C-]>

" Calculate column number with padding added for airline
function! Column()
    redir =>l:a |exe "sil sign place buffer=".bufnr('')|redir end
    let l:signlist=split(l:a, '\n')
    let padding=&numberwidth + &foldcolumn + (len(signlist) > 2 ? 2 : 0)
    let vc = virtcol('.')
    let column_width = strlen(vc)
    let padding = padding - column_width
    let column = ''

    if padding <= 1
        let column .= vc
    else
        let column .= repeat(' ', padding - 2) . vc
    endif

    return column
endfunction
call airline#parts#define_function('column', 'Column')

" ================================== PLUGINS ===================================

" CtrlP
let g:ctrlp_custom_ignore = 'node_modules'
nmap <Leader>f :CtrlP<CR>
map <Leader>gf :CtrlP %%<CR>

" Indexed search
let g:indexed_search_mappings = 0
nnoremap <silent> * *:ShowSearchIndex<CR>
vnoremap <silent> * *:ShowSearchIndex<CR>
nnoremap <silent> # #:ShowSearchIndex<CR>
vnoremap <silent> # #:ShowSearchIndex<CR>
nnoremap <silent> n n:ShowSearchIndex<CR>
vnoremap <silent> n n:ShowSearchIndex<CR>
nnoremap <silent> N N:ShowSearchIndex<CR>
vnoremap <silent> N N:ShowSearchIndex<CR>

" Airline
let g:airline#extensions#tabline#enabled   = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline#extensions#default#layout = [
    \ [ 'b', 'c' ],
    \ [ 'x', 'warning', 'error' ]
    \ ]

" Redefine the content of some sections
function! AirlineInit()
    let g:airline_section_b = airline#section#create_left(['column'])
    let g:airline_section_x = airline#section#create_right(['branch'])
endfunction
autocmd User AirlineAfterInit call AirlineInit()

" Syntastic
let g:syntastic_puppet_checkers = ['puppetlint']
let g:syntastic_python_checkers = ['flake8', 'pep8']
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_sh_shellcheck_args = "-x -e SC1090 -e SC1091"

" YouCompleteMe
let g:ycm_python_binary_path = 'python'
let g:ycm_autoclose_preview_window_after_insertion = 1
